export default function Hero() {
    return (
        <div className="relative pt-32 pb-20 sm:pt-40 sm:pb-24 overflow-hidden">
            {/* Background Elements */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full max-w-7xl pointer-events-none">
                <div className="absolute top-[10%] left-[20%] w-72 h-72 bg-purple-600/30 rounded-full blur-[100px]" />
                <div className="absolute top-[30%] right-[20%] w-96 h-96 bg-pink-600/20 rounded-full blur-[120px]" />
            </div>

            <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/5 border border-white/10 mb-8 backdrop-blur-md">
                    <span className="flex h-2 w-2 rounded-full bg-green-400 animate-pulse"></span>
                    <span className="text-sm font-medium text-gray-300">Updated for macOS Sequoia (2026)</span>
                </div>

                <h1 className="text-5xl sm:text-7xl font-bold tracking-tight mb-8">
                    Is Your Mac Startup Disk <br />
                    <span className="text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-400 to-purple-400 animate-gradient-x">
                        Almost Full?
                    </span>
                </h1>

                <p className="max-w-2xl mx-auto text-xl text-gray-400 mb-10 leading-relaxed">
                    Running out of space slows down your Mac. We tested the most popular disk cleaners to help you reclaim your storage in seconds.
                </p>

                <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                    <a
                        href="#comparison"
                        className="px-8 py-4 rounded-full bg-white text-purple-900 font-bold hover:bg-gray-100 transition-all transform hover:scale-105 shadow-xl shadow-purple-900/20"
                    >
                        See the Comparison
                    </a>
                    <a
                        href="https://getdiskspace.com"
                        target="_blank"
                        className="px-8 py-4 rounded-full bg-white/5 text-white font-medium hover:bg-white/10 border border-white/10 transition-all"
                    >
                        Visit Our Top Pick
                    </a>
                </div>
            </div>
        </div>
    );
}
