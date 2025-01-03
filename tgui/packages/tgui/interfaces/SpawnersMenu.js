import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Tooltip, Tabs } from '../components';
import { Window } from '../layouts';

export const SpawnersMenu = (props, context) => {
  return (
    <Window
      title="Spawners Menu"
      width={700}
      height={600}>
      <Window.Content overflow="auto">
		<SpawnerContent />
		</Window.Content>
	</Window>
	);
};

export const SpawnerContent = (props, context) => {
	const { act, data } = useBackend(context);

	return (
		<Box>
			<Section fitted>
				<Tabs>
					<Tabs.Tab
						icon="list"
						selected={tab === 'misc'}
						onClick={() => setTab('misc')}>
						Misc ({misc.length})
					</Tabs.Tab>
					<Tabs.Tab
						icon="user"
						selected={tab === 'ds'}
						onClick={() => setTab('ds')}>
						Deep Space ({ds.length})
					</Tabs.Tab>
					<Tabs.Tab
						icon="weapon"
						selected={tab === 'inteq'}
						onClick={() => setTab('inteq')}>
						InteQ ({inteq.length})
					</Tabs.Tab>
					<Tabs.Tab
						icon="time"
						selected={tab === 'midround'}
						onClick={() => setTab('midround')}>
						Mid-Round ({midround.length})
					</Tabs.Tab>
				</Tabs>
			</Section>
			{tab === 'misc' && (
        <RolelistMisc />
      )}
      {tab === 'ds' && (
        <RolelistDS />
      )}
      {tab === 'inteq' && (
        <RolelistInteq />
      )}
			{tab === 'midround' && (
				<RolelistMidround />
      )}
		</Box>
	)
};

export const RolelistItem = (props, context) => {
	const spawner = data.spawner || [];

	return (
		<Section
			key={spawner.name}
			title={spawner.name + ' (' + spawner.amount_left + ' left)'}
			level={2}
			buttons={(
				<>
				<Tooltip content={spawner.can_load_appearance === 2
					? "This role forces using your characters."
					: spawner.can_load_appearance
					? "This role allows using your characters."
					: "This role does not allow using your characters."}>
					<Icon name="user" mr="4px"
					color={spawner.can_load_appearance === 2 ? "yellow"
						: spawner.can_load_appearance ? "green" : "red"} />
				</Tooltip>
				<Button
					content="Jump"
					onClick={() => act('jump', {
					name: spawner.name,
					})} />
				<Button
					content="Spawn"
					onClick={() => act('spawn', {
					name: spawner.name,
					})} />
				</>
			)}>
			<Box
				bold
				mb={1}
				fontSize="20px">
				{spawner.short_desc}
			</Box>
			<Box>
				{spawner.flavor_text}
			</Box>
			{!!spawner.important_info && (
				<Box
				mt={1}
				bold
				color="bad"
				fontSize="26px">
				{spawner.important_info}
				</Box>
			)}
			</Section>
		)
	
}

export const RolelistMisc = (props, context) => {
	
}