import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import Link from 'next/link';
import { articles } from '@/data/articles';

export default function BlogIndex() {
    return (
        <div className="min-h-screen flex flex-col bg-black text-white selection:bg-purple-500/30">
            <Navbar />

            <main className="flex-grow pt-32 pb-20">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

                    <div className="text-center mb-16">
                        <h1 className="text-4xl sm:text-5xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-400">
                            Tips & Guides
                        </h1>
                        <p className="text-xl text-gray-400 max-w-2xl mx-auto">
                            Expert advice on keeping your Mac fast, clean, and organized.
                        </p>
                    </div>

                    <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
                        {articles.map((article) => (
                            <Link
                                key={article.id}
                                href={`/blog/${article.slug}`}
                                className="group block h-full"
                            >
                                <article className="h-full p-6 rounded-2xl glass-panel border border-[var(--border-glass)] bg-white/5 hover:bg-white/10 transition-all hover:scale-[1.02]">
                                    <div className="flex flex-col h-full">
                                        <div className="mb-4">
                                            <span className="text-sm text-purple-400 font-medium">
                                                {new Date(article.date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
                                            </span>
                                        </div>
                                        <h2 className="text-xl font-bold mb-3 group-hover:text-purple-300 transition-colors">
                                            {article.title}
                                        </h2>
                                        <p className="text-gray-400 mb-6 flex-grow line-clamp-3">
                                            {article.excerpt}
                                        </p>
                                        <div className="flex items-center text-sm font-medium text-white group-hover:underline">
                                            Read Guide →
                                        </div>
                                    </div>
                                </article>
                            </Link>
                        ))}
                    </div>

                </div>
            </main>

            <Footer />
        </div>
    );
}
