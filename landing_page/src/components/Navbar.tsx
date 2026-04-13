import { motion } from "motion/react";
import { Package } from "lucide-react";

export default function Navbar() {
  return (
    <nav className="sticky top-0 z-50 w-full bg-surface/80 backdrop-blur-md">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-8 py-4">
        <div className="flex items-center gap-2">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary shadow-lg shadow-primary/20">
            <Package className="h-6 w-6 text-on-primary" />
          </div>
          <div className="font-headline text-2xl font-black text-primary">
            Stock Flow
          </div>
        </div>
        
        <div className="hidden items-center gap-8 md:flex">
          <a href="#features" className="font-headline text-lg font-bold text-on-surface-variant hover:text-primary transition-colors">
            Características
          </a>
          <a href="#pricing" className="font-headline text-lg font-bold text-on-surface-variant hover:text-primary transition-colors">
            Precios
          </a>
          <a href="#contact" className="font-headline text-lg font-bold text-on-surface-variant hover:text-primary transition-colors">
            Contacto
          </a>
          <motion.button 
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="rounded-md bg-primary px-6 py-2.5 font-medium text-on-primary shadow-sm hover:opacity-90"
          >
            Descargar gratis
          </motion.button>
        </div>

        <div className="md:hidden text-primary">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="18" y2="18"/></svg>
        </div>
      </div>
    </nav>
  );
}
