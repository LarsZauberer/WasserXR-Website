// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'WasserXR',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/LarsZauberer/TheSeed' }],
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
