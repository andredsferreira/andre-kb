export interface ResourceLink {
  href: string;
  title: string;
  description: string;
  ariaLabel: string;
}

export const nextJsResources: ResourceLink[] = [
  {
    href: "https://nextjs.org/docs",
    title: "Documentation",
    description:
      "Find in-depth information about Next.js features and API.",
    ariaLabel: "Next.js documentation",
  },
  {
    href: "https://vercel.com/templates?framework=next.js",
    title: "Templates",
    description:
      "Browse and deploy Next.js templates to get started quickly!",
    ariaLabel: "Browse Next.js templates",
  },
  {
    href: "https://github.com/vercel/next.js/tree/canary/examples",
    title: "Examples",
    description:
      "Discover and deploy boilerplate example Next.js projects.",
    ariaLabel: "View Next.js examples",
  },
  {
    href: "https://vercel.com/new?utm_source=create-next-app&utm_medium=default-template&utm_campaign=create-next-app",
    title: "Deploy",
    description:
      "Instantly deploy your Next.js site to a public URL with Vercel.",
    ariaLabel: "Deploy to Vercel",
  },
];

export const dockerResources: ResourceLink[] = [
  {
    href: "https://github.com/kristiyan-velkov/frontend-production-dockerfiles",
    title: "Front-end Production Dockerfiles",
    description:
      "Production-ready Dockerfiles for React.js, Angular, Vue.js, and Next.js. Optimized for performance, security, and minimal image size.",
    ariaLabel: "Front-end production Dockerfiles on GitHub",
  },
  {
    href: "https://docs.docker.com/get-started/",
    title: "Learn Docker",
    description:
      "Get started with Docker! Learn fundamentals, containerization, and deployment.",
    ariaLabel: "Learn Docker fundamentals",
  },
  {
    href: "https://docs.docker.com/",
    title: "Docker Docs",
    description:
      "Comprehensive Docker documentation and reference guides.",
    ariaLabel: "Browse Docker documentation",
  },
  {
    href: "https://docs.docker.com/language/nodejs/",
    title: "React.js Guide",
    description:
      "Official Docker guide for React.js applications following best practices for containerization.",
    ariaLabel: "Read React.js Docker guide",
  },
];
