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
					label: 'Blog',
					items: [
						{ slug: 'blog' },
						{ slug: 'blog/rewriting-wasserxr-in-rust' },
						{ slug: 'blog/welcome' },
					],
				},
				{
					label: 'Getting Started',
					items: [
						{ slug: 'getting_started/setup' },
						{
							label: 'ECS',
							autogenerate: { directory: 'getting_started/ECS' },
						},
						{ slug: 'getting_started/logging' },
					],
				},
        {
          label: 'WasserXR-Core',
          items: [
            {label: 'Components', autogenerate: {directory: 'wasserxr-core/components'}},
            {label: 'Systems', autogenerate: {directory: 'wasserxr-core/systems'}}
          ]
        }
			],
		}),
	],
});
