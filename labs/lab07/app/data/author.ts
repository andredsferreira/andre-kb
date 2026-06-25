export interface SocialLink {
  label: string;
  href: string;
  icon: "github" | "linkedin" | "twitter" | "x" | "website";
}

export interface Author {
  name: string;
  tagline: string;
  dockerCaptain?: boolean;
  social: SocialLink[];
}

export const author: Author = {
  name: "Kristiyan Velkov",
  tagline: "Developer · Docker & Next.js",
  dockerCaptain: true,
  social: [
    {
      label: "GitHub",
      href: "https://github.com/kristiyan-velkov/docker-docs",
      icon: "github",
    },
    {
      label: "LinkedIn",
      href: "https://www.linkedin.com/in/kristiyan-velkov-763130b3/",
      icon: "linkedin",
    },
    {
      label: "X",
      href: "https://x.com/krisvelkov",
      icon: "x",
    },
  ],
};
