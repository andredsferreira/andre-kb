import type { Author } from "../../data/author";
import AuthorBanner from "./AuthorBanner";

interface PageFooterProps {
  author: Author;
}

export default function PageFooter({ author }: PageFooterProps) {
  return (
    <footer className="mt-16 pt-8">
      <AuthorBanner author={author} />
    </footer>
  );
}
