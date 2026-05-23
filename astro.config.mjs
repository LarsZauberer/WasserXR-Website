// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'WasserXR',
			customCss: ['./src/styles/custom.css'],
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/LarsZauberer/TheSeed' }, {icon: "discord", label: "Discord", href: "https://discord.gg/XcjBZn5pHy"}],
			sidebar: [
				{
					label: 'Getting Started',
          autogenerate: {directory: "getting_started"},
				},
				// {
				// 	label: 'Reference',
				// 	autogenerate: { directory: 'reference' },
				// },
			],
		}),
	],
});
