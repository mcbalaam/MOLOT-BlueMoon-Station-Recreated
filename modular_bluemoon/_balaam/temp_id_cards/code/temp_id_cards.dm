/obj/item/card/id/temp 
	name = "temporary access voucher"
	desc = "A cardboard punchcard that provides temporary access to specified areas."
	icon = './modular_bluemoon/_balaam/temp_id_cards/icons/id.dmi'
	icon_state = "id_card"
	resistance_flags = null
	bank_support = ID_NO_BANK_ACCOUNT
	mining_support = FALSE
	access = list()

	/// List of departments the voucher provides access to.
	var/list/access_departments = list()
	/// The character the voucher has been issued to.
	var/owner_name = null
	/// World time at which the voucher was issued.
	var/issue_time = null
	/// The voucher's expiration time. It will loose it's access when it expires.
	var/expires_in = 5 MINUTES
	/// If the voucher has already expired.
	var/expired = FALSE
	/// List of all departments. 
	var/static/list/all_departments = list(
		DEPARTMENT_ENGINEERING = "engi",
		DEPARTMENT_COMMAND = "comm",
		DEPARTMENT_SECURITY = "sec",
		DEPARTMENT_SUPPLY = "sup",
		DEPARTMENT_SERVICE = "serv",
		DEPARTMENT_SCIENCE = "sci",
	)

	var/list/newaccess = list()

/obj/item/card/id/temp/Initialize(mapload, newaccess)
	. = ..()
	access += newaccess
	issue_time = world.time - SSticker.round_start_time
	say("[issue_time]")
	update_appearance(UPDATE_OVERLAYS)

/obj/item/card/id/temp/examine(mob/user)
	. = ..()
	var/department_list_string = ""
	var/i = 1

	while (i <= length(access_departments))
		var/each_department = access_departments[i]
		department_list_string += each_department
		if (i < (length(access_departments) - 1))
			department_list_string += ", "
		else if (i == (length(access_departments) - 1))
			department_list_string += " and "
		i += 1

	. += "<hr>"
	. += "<span class='notice'>This voucher [length(department_list_string) == 0 ? "<b>does not provide any access</b>" : "provides access to <b>[lowertext(department_list_string)]</b>"].</span>"
	. += "<span class='notice'><i>You can take a closer look to see which areas it provides access to.</i></span>"
	. += "<hr>"
	. += "This voucher was[owner_name == null ? "n't issued to anyone" : "issued to <b>[owner_name]</b>"]."
	if (expired)
		. += "This voucher is <b>expired</b>."
	else
		. += "This voucher [issue_time == null ? "has no expiration date" : "will expire at <b>[issue_time]</b>"]."

/obj/item/card/id/temp/update_overlays()
	. = ..()
	if (!length(access_departments) == 0)
		. += "text"
	if (length(access_departments) == 1)
		. += "stamp-[(all_departments[access_departments[1]])]"
	else if (length(access_departments) > 1)
		. += "stamp-comm"

/obj/item/card/id/temp/attack_self(mob/user)
	return

/obj/item/card/id/temp/engineering
	newaccess = list(ACCESS_ENGINE)
	access_departments = list(DEPARTMENT_ENGINEERING, DEPARTMENT_SUPPLY)

