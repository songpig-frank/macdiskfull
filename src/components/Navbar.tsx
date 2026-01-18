'use client';

import Link from 'next/link';
import { Menu, X, HardDrive } from 'lucide-react';
import { useState } from 'react';

export default function Navbar() {
    const [isOpen, setIsOpen] = useState(false);

    return (
        <nav className="fixed top-0 left-0 right-0 z-50 glass-panel border-b border-[var(--border-glass)] bg-[var(--bg-glass)]">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between h-16">
                    <div className="flex items-center gap-2">
                        <Link href="/" className="flex items-center gap-2 group">
                            <div className="p-2 bg-gradient-to-br from-purple-600 to-pink-600 rounded-lg group-hover:scale-105 transition-transform">
                                <HardDrive className="h-5 w-5 text-white" />
                            </div>
                            <span className="font-bold text-xl tracking-tight text-white group-hover:text-purple-300 transition-colors">
                                MacDiskFull<span className="text-purple-500">.com</span>
                            </span>
                        </Link>
                    </div>

                    <div className="hidden md:block">
                        <div className="ml-10 flex items-baseline space-x-8">
                            <Link href="/" className="hover:text-white text-gray-300 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                Reviews
                            </Link>
                            <Link href="/comparisons" className="hover:text-white text-gray-300 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                Comparisons
                            </Link>
                            <Link href="/blog" className="hover:text-white text-gray-300 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                Tips & Guide
                            </Link>
                            <Link
                                href="https://getdiskspace.com"
                                target="_blank"
                                className="bg-white text-black hover:bg-purple-100 px-4 py-2 rounded-full text-sm font-bold transition-all transform hover:scale-105"
                            >
                                Get Recommended Tool
                            </Link>
                        </div>
                    </div>

                    <div className="-mr-2 flex md:hidden">
                        <button
                            onClick={() => setIsOpen(!isOpen)}
                            className="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-white hover:bg-white/10 focus:outline-none"
                        >
                            {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
                        </button>
                    </div>
                </div>
            </div>

            {isOpen && (
                <div className="md:hidden glass-panel border-b border-[var(--border-glass)]">
                    <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
                        <Link href="/" className="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                            Reviews
                        </Link>
                        <Link href="/comparisons" className="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                            Comparisons
                        </Link>
                        <Link href="/blog" className="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                            Tips & Guide
                        </Link>
                        <Link
                            href="https://getdiskspace.com"
                            target="_blank"
                            className="text-white bg-purple-600 hover:bg-purple-700 block px-3 py-2 rounded-md text-base font-medium mt-4 text-center"
                        >
                            Get Recommended Tool
                        </Link>
                    </div>
                </div>
            )}
        </nav>
    );
}
