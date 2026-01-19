import type { Metadata } from 'next';
import { Outfit } from 'next/font/google';
import './globals.css';

const outfit = Outfit({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'MacDiskFull.com | Best Mac Cleaner Software Compared (2026)',
  description: 'Is your Mac disk full? Compare the best Mac cleaner software to free up space. We review GetDiskSpace, CleanMyMac, and more to help you decide.',
  icons: {
    icon: '/favicon.png', // We'll need to make this or use default
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={outfit.className}>{children}</body>
    </html>
  );
}
