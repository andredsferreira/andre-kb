import Link from "next/link";
import type { Author, SocialLink } from "../../data/author";

function SocialIcon({ icon }: { icon: SocialLink["icon"] }) {
  const className = "w-5 h-5 shrink-0";
  switch (icon) {
    case "github":
      return (
        <svg className={className} fill="currentColor" viewBox="0 0 24 24" aria-hidden>
          <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
        </svg>
      );
    case "linkedin":
      return (
        <svg className={className} fill="currentColor" viewBox="0 0 24 24" aria-hidden>
          <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
        </svg>
      );
    case "twitter":
    case "x":
      return (
        <svg className={className} fill="currentColor" viewBox="0 0 24 24" aria-hidden>
          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
        </svg>
      );
    default:
      return (
        <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden>
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
        </svg>
      );
  }
}

function DockerIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M13.983 10.779h2.738v2.668h-2.738v-2.668zm-3.404 0h2.738v2.668h-2.738v-2.668zm-3.404 0h2.738v2.668H7.175v-2.668zm-3.404 0h2.738v2.668H3.771v-2.668zM20.746 8.112h-2.738v2.668h2.738V8.112zm-3.404 0h-2.738v2.668h2.738V8.112zm-3.404 0h-2.738v2.668h2.738V8.112zm-3.404 0H7.175v2.668h2.738V8.112zm-3.404 0H3.771v2.668h2.738V8.112zM20.746 5.444h-2.738v2.668h2.738V5.444zm-3.404 0h-2.738v2.668h2.738V5.444zm-3.404 0h-2.738v2.668h2.738V5.444zm-3.404 0H7.175v2.668h2.738V5.444zM10.579 2.776H7.841v2.668h2.738V2.776zm-3.404 0H3.771v2.668h2.738V2.776zm10.212 0h-2.738v2.668h2.738V2.776zm3.404 0h-2.738v2.668h2.738V2.776zM4.882 18.668h14.236V8.112H4.882v10.556zM24 6.668V20c0 1.473-1.194 2.668-2.668 2.668H2.668C1.194 22.668 0 21.473 0 20V6.668h2.668V4H0V2.668C0 1.194 1.194 0 2.668 0h18.664C22.806 0 24 1.194 24 2.668v4H21.332v2.668H24z" />
    </svg>
  );
}

const socialStyles: Record<SocialLink["icon"], string> = {
  github: "hover:bg-zinc-800 hover:text-white hover:border-zinc-800 focus:ring-zinc-500",
  linkedin: "hover:bg-[#0A66C2] hover:text-white hover:border-[#0A66C2] focus:ring-[#0A66C2]",
  twitter: "hover:bg-black hover:text-white hover:border-black focus:ring-black",
  x: "hover:bg-black hover:text-white hover:border-black focus:ring-black",
  website: "hover:bg-zinc-700 hover:text-white hover:border-zinc-700 focus:ring-zinc-500",
};

export default function AuthorBanner({ author }: { author: Author }) {
  return (
    <aside
      className="mt-auto border-t border-zinc-200 bg-gradient-to-b from-zinc-50 to-zinc-100/90"
      aria-label="About the author"
    >
      <div className="container mx-auto px-4 py-10">
        <div className="max-w-2xl mx-auto text-center">
          <p className="text-xs font-semibold uppercase tracking-widest text-zinc-400 mb-2">
            Created by
          </p>
          <div className="flex flex-wrap items-center justify-center gap-2 mb-1">
            <h3 className="text-xl font-bold text-zinc-900">{author.name}</h3>
            {author.dockerCaptain && (
              <Link
                href="https://www.docker.com/blog/from-the-captains-chair-kristiyan-velkov/"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 rounded-full bg-[#2496ED] px-3 py-1 text-xs font-bold uppercase tracking-wide text-white shadow-sm transition-all hover:bg-[#1e7bc2] hover:shadow focus:outline-none focus:ring-2 focus:ring-[#2496ED] focus:ring-offset-2"
                aria-label="Docker Captain - Docker Community expert"
              >
                <DockerIcon className="w-3.5 h-3.5" />
                Docker Captain
              </Link>
            )}
          </div>
          <p className="text-sm text-zinc-600 mb-8">{author.tagline}</p>
          <nav
            className="flex flex-wrap items-center justify-center gap-3"
            aria-label="Author social links"
          >
            {author.social.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
                className={`
                  inline-flex items-center gap-2 rounded-full border-2 border-zinc-300 bg-white px-5 py-2.5 text-sm font-semibold text-zinc-700
                  transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2
                  ${socialStyles[link.icon] ?? socialStyles.website}
                `}
                aria-label={link.label}
              >
                <SocialIcon icon={link.icon} />
                <span>{link.label}</span>
              </Link>
            ))}
          </nav>
        </div>
      </div>
    </aside>
  );
}
