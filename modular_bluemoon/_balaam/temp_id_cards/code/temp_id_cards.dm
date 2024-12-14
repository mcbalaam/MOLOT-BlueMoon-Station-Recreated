/obj/item/card/id/temp 
	name = "temporary access permit"
	desc = "A cardboard punchcard that provides temporary access to specified departments."
	icon = './modular_bluemoon/_balaam/temp_id_cards/icons/id.dmi'
	icon_state = "id_card"
	resistance_flags = null
	bank_support = ID_NO_BANK_ACCOUNT
	mining_support = FALSE

	/// List of departments the card provides access to.
	var/list/access_departments = list()
	/// The character the card has been issued to.
	var/owner_name = null
	/// The card's expiration time. The card will loose it's access when it expires.
	var/expiration_time = null
	/// List of all departments. 
	var/static/list/all_departments = list(
		DEPARTMENT_ENGINEERING = "engi",
		DEPARTMENT_COMMAND = "comm",
		DEPARTMENT_SECURITY = "sec",
		DEPARTMENT_SUPPLY = "sup",
		DEPARTMENT_SERVICE = "serv",
		DEPARTMENT_SCIENCE = "sci",
	)

/obj/item/card/id/temp/Initialize(mapload, newaccess)
	. = ..()
	newaccess = ACCESS_ENGINE
	access += newaccess
	say_test("initialized [newaccess]")
	update_appearance(UPDATE_OVERLAYS)

/obj/item/card/id/temp/examine(mob/user)
	. = ..()
	. += "This card provides access to <b>[access_departments]</b>."
	. += "This card was[owner_name == null ? "n't issued to anyone" : "issued to <b>[owner_name]</b>"]."
	. += "The card [expiration_time == null ? "has no expiration date" : "will expire at <b>[expiration_time]</b>"]."

/obj/item/card/id/temp/update_overlays()
	. = ..()
	. += "text"
	. += "stamp-comm"
	if (length(access_departments) == 1)
		. += "stamp-comm"
	else 
		. += "stamp-[access_departments[1]]"

/obj/item/card/id/temp/attack_self(mob/user)
	return

/obj/item/card/id/temp/engineering
	var/list/newaccess = list(ACCESS_ENGINE)
	access_departments = list(DEPARTMENT_ENGINEERING)

