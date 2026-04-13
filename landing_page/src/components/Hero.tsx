import { motion } from "motion/react";
import { ArrowRight, Sparkles } from "lucide-react";

export default function Hero() {
  return (
    <header className="relative overflow-hidden px-8 pt-16 pb-24 md:pt-24 md:pb-32">
      <div className="mx-auto grid max-w-7xl grid-cols-1 items-center gap-12 lg:grid-cols-2">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="z-10"
        >
          <h1 className="mb-6 font-headline text-5xl font-black leading-tight tracking-tight text-on-surface md:text-7xl">
            Tu inventario, inteligente y <span className="italic text-primary">sin complicaciones</span>
          </h1>
          <p className="mb-10 max-w-xl text-xl leading-relaxed text-on-surface-variant">
            Diseñado para las PyMEs de México. Controla tu stock con el poder de la IA, desde tu celular y con la calidez de un proceso artesanal.
          </p>
          <div className="flex flex-wrap gap-4">
            <motion.button 
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="flex items-center gap-2 rounded-xl bg-primary px-8 py-4 text-lg font-bold text-on-primary shadow-xl shadow-primary/10"
            >
              Comenzar Ahora
              <ArrowRight className="h-5 w-5" />
            </motion.button>
            <motion.button 
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="rounded-xl bg-surface-container-high px-8 py-4 text-lg font-bold text-primary transition-all hover:bg-surface-container-highest"
            >
              Ver Demo
            </motion.button>
          </div>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="relative flex justify-center lg:justify-end"
        >
          <div className="relative w-full max-w-[400px]">
            <div className="absolute -inset-4 rounded-full bg-primary-container blur-3xl opacity-20"></div>
            <div className="relative rounded-[3rem] border border-white/10 glass-panel p-4 shadow-2xl">
              <img 
                src="https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&q=80&w=800" 
                alt="Stock Flow App" 
                className="w-full rounded-[2.5rem] shadow-inner"
                referrerPolicy="no-referrer"
              />
            </div>
            
            <motion.div 
              animate={{ y: [0, -10, 0] }}
              transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
              className="absolute -left-8 top-1/4 flex items-center gap-3 rounded-2xl border border-primary/10 glass-panel px-4 py-3 shadow-lg pulse-ai"
            >
              <Sparkles className="h-5 w-5 text-primary fill-primary" />
              <span className="text-sm font-bold text-on-surface">Predicción de Stock Activa</span>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </header>
  );
}
