import Link from "next/link";
import type { ResourceLink } from "../../data/resources";

const cardClassName =
  "bg-white rounded-lg p-6 shadow-md border border-zinc-200 hover:shadow-lg transition-shadow group focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 block";

export default function ResourceCard({ resource }: { resource: ResourceLink }) {
  return (
    <Link
      href={resource.href}
      target="_blank"
      rel="noopener noreferrer"
      className={cardClassName}
      aria-label={resource.ariaLabel}
    >
      <h3 className="text-lg font-semibold mb-2 text-black group-hover:text-blue-600">
        {resource.title} →
      </h3>
      <p className="text-zinc-600 text-sm">{resource.description}</p>
    </Link>
  );
}
