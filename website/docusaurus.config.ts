import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'TickTock',
  tagline: 'Modern Time Tracking for macOS',
  favicon: 'img/favicon.ico',

  url: 'https://sebakri.github.io',
  baseUrl: '/ticktock/',

  organizationName: 'sebakri',
  projectName: 'ticktock',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  stylesheets: [
    {
      href: 'https://fonts.googleapis.com/css2?family=Fascinate&family=Inter:wght@400;600;700&display=swap',
      type: 'text/css',
    },
  ],

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/sebakri/ticktock/tree/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'TickTock',
      logo: {
        alt: 'TickTock Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://github.com/sebakri/ticktock',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/intro',
            },
            {
              label: 'Shortcuts',
              to: '/docs/shortcuts',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/sebakri/ticktock',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} sebakri. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;