import { CheckCircle2, BrainCircuit, Mic } from "lucide-react";
import { motion } from "motion/react";

export default function HowItWorks() {
  return (
    <section className="bg-surface-container-high px-8 py-24">
      <div className="mx-auto max-w-7xl">
        <h2 className="mb-16 text-center font-headline text-4xl font-bold md:text-5xl">
          Cómo funciona la magia
        </h2>
        
        <div className="grid grid-cols-1 items-stretch gap-8 md:grid-cols-12">
          {/* Step 1 */}
          <div className="flex flex-col justify-between rounded-3xl bg-surface-container-lowest p-10 md:col-span-4">
            <div>
              <span className="font-headline text-7xl font-black leading-none text-primary/10">01</span>
              <h4 className="mt-4 mb-4 font-headline text-2xl font-bold">Fotografía tu factura</h4>
              <p className="text-on-surface-variant">Sube una imagen de tu recibo de proveedor o una foto de los nuevos productos.</p>
            </div>
            <div className="mt-8 overflow-hidden rounded-2xl border border-surface-container-highest">
              <img 
                src="https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&q=80&w=400" 
                alt="Scanning" 
                className="h-32 w-full object-cover"
                referrerPolicy="no-referrer"
              />
            </div>
          </div>

          {/* Step 2 */}
          <div className="relative z-10 flex flex-col justify-between rounded-3xl bg-primary p-10 text-on-primary shadow-2xl md:col-span-8">
            <div>
              <span className="font-headline text-7xl font-black leading-none text-white/20">02</span>
              <h4 className="mt-4 mb-4 font-headline text-2xl font-bold">La IA extrae los datos</h4>
              <p className="opacity-90">Nuestros modelos procesan la información, identifican cantidades y precios automáticamente. Sin errores de captura.</p>
            </div>
            <div className="mt-8 rounded-2xl border border-white/20 bg-white/10 p-6 backdrop-blur-sm">
              <div className="flex animate-pulse items-center gap-4">
                <BrainCircuit className="h-10 w-10" />
                <div className="flex-1 space-y-2">
                  <div className="h-2 w-3/4 rounded bg-white/30"></div>
                  <div className="h-2 w-1/2 rounded bg-white/30"></div>
                </div>
              </div>
            </div>
          </div>

          {/* Step 3 - Voice Control */}
          <div className="relative z-10 flex flex-col justify-between rounded-3xl bg-tertiary p-10 text-on-primary shadow-2xl md:col-span-8">
            <div>
              <span className="font-headline text-7xl font-black leading-none text-white/20">03</span>
              <h4 className="mt-4 mb-4 font-headline text-2xl font-bold">Gestión por voz</h4>
              <p className="opacity-90">Registra entradas y salidas o consulta existencias simplemente hablando. "Saca 5 cajas de leche" o "¿Cuánto café queda?". La app entiende el contexto de tu negocio.</p>
            </div>
            <div className="mt-8 flex items-center justify-center gap-6">
              <div className="flex items-end gap-1.5 h-12">
                {[0.4, 0.7, 1, 0.6, 0.8, 0.5, 0.9, 0.4].map((h, i) => (
                  <motion.div 
                    key={i}
                    animate={{ height: [`${h*100}%`, `${(1-h)*100}%`, `${h*100}%`] }}
                    transition={{ duration: 1.5, repeat: Infinity, delay: i * 0.1 }}
                    className="w-2 bg-white/40 rounded-full"
                  />
                ))}
              </div>
              <div className="rounded-full bg-white/20 p-4">
                <Mic className="h-10 w-10 text-white" />
              </div>
            </div>
          </div>

          {/* Step 4 */}
          <div className="flex flex-col justify-between rounded-3xl bg-surface-container-lowest p-10 md:col-span-4">
            <div>
              <span className="font-headline text-7xl font-black leading-none text-primary/10">04</span>
              <h4 className="mt-4 mb-4 font-headline text-2xl font-bold">Inventario actualizado</h4>
              <p className="text-on-surface-variant">Tu catálogo se sincroniza en todos tus dispositivos en tiempo real. Control total sin esfuerzo.</p>
            </div>
            <div className="mt-8 flex justify-center">
              <CheckCircle2 className="h-20 w-20 text-tertiary" />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
