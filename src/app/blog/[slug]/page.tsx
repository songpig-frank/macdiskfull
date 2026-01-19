import { articles } from '@/data/articles';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { notFound } from 'next/navigation';
import ReactMarkdown from 'react-markdown';
import Link from 'next/link';
import { ArrowLeft, User, Calendar } from 'lucide-react';

interface BlogPostProps {
    params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
    return articles.map((article) => ({
        slug: article.slug,
    }));
}

export default async function BlogPost({ params }: BlogPostProps) {
    const { slug } = await params;

    // Find article
    const article = articles.find((p) => p.slug === slug);

    if (!article) {
        notFound();
    }

    return (
        <div className="min-h-screen flex flex-col bg-black text-white selection:bg-purple-500/30">
            <Navbar />

            <main className="flex-grow pt-32 pb-20">
                <article className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">

                    {/* Back Link */}
                    <Link href="/blog" className="inline-flex items-center text-gray-400 hover:text-white mb-8 transition-colors group">
                        <ArrowLeft className="mr-2 h-4 w-4 group-hover:-translate-x-1 transition-transform" />
                        Back to Articles
                    </Link>

                    {/* Header */}
                    <header className="mb-12">
                        <h1 className="text-3xl sm:text-5xl font-bold mb-6 leading-tight bg-clip-text text-transparent bg-gradient-to-r from-white to-gray-300">
                            {article.title}
                        </h1>

                        <div className="flex items-center gap-6 text-gray-400 text-sm border-b border-white/10 pb-8">
                            <div className="flex items-center gap-2">
                                <User className="h-4 w-4 text-purple-400" />
                                <span>{article.author}</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <Calendar className="h-4 w-4 text-purple-400" />
                                <span>{new Date(article.date).toLocaleDateString()}</span>
                            </div>
                        </div>
                    </header>

                    {/* Content */}
                    <div className="prose prose-invert prose-lg max-w-none 
                        prose-headings:text-white prose-p:text-gray-300 prose-a:text-purple-400 hover:prose-a:text-purple-300
                        prose-strong:text-white prose-code:text-pink-300
                        prose-li:text-gray-300">
                        <ReactMarkdown>
                            {article.content}
                        </ReactMarkdown>
                    </div>

                </article>
            </main>

            <Footer />
        </div>
    );
}
