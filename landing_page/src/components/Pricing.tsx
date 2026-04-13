import { Check } from "lucide-react";
import { motion } from "motion/react";

const plans = [
  {
    name: "Starter",
    price: "Gratis",
    features: ["Hasta 50 productos", "1 usuario admin", "Escaneo básico"],
    buttonText: "Elegir Gratis",
    highlight: false
  },
  {
    name: "Pro",
    price: "$299",
    period: "/mes",
    features: ["Productos ilimitados", "3 usuarios simultáneos", "IA predictiva de ventas", "Reportes en PDF/Excel"],
    buttonText: "Probar 14 días gratis",
    highlight: true
  },
  {
    name: "Business",
    price: "$799",
    period: "/mes",
    features: ["Múltiples sucursales", "Usuarios ilimitados", "Soporte prioritario 24/7"],
    buttonText: "Contactar Ventas",
    highlight: false
  }
];

export default function Pricing() {
  return (
    <section id="pricing" className="bg-surface px-8 py-24">
      <div className="mx-auto max-w-7xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-headline text-4xl font-bold md:text-5xl">Planes para cada etapa</h2>
          <p className="text-on-surface-variant">Sin letras chiquitas, solo crecimiento.</p>
        </div>

        <div className="grid grid-cols-1 items-end gap-8 md:grid-cols-3">
          {plans.map((plan, index) => (
            <div 
              key={index}
              className={`flex flex-col rounded-3xl p-10 transition-all ${
                plan.highlight 
                  ? "relative z-10 scale-105 border-4 border-primary bg-surface-container-lowest shadow-2xl ring-8 ring-primary/5" 
                  : "border border-surface-container-highest bg-surface-container-low"
              }`}
            >
              {plan.highlight && (
                <div className="absolute -top-5 left-1/2 -translate-x-1/2 rounded-full bg-primary px-6 py-1 text-sm font-bold uppercase tracking-widest text-on-primary">
                  Más popular
                </div>
              )}
              <h3 className="mb-2 font-headline text-2xl font-bold">{plan.name}</h3>
              <div className="mb-6 flex items-baseline gap-1">
                <span className="font-headline text-4xl font-black text-on-surface">{plan.price}</span>
                {plan.period && <span className="text-on-surface-variant">{plan.period}</span>}
              </div>
              <ul className="mb-10 flex-1 space-y-4">
                {plan.features.map((feature, fIndex) => (
                  <li key={fIndex} className="flex items-center gap-3 text-on-surface-variant">
                    <Check className="h-5 w-5 text-tertiary" />
                    {feature}
                  </li>
                ))}
              </ul>
              <motion.button 
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className={`w-full rounded-xl py-4 font-bold transition-colors ${
                  plan.highlight 
                    ? "bg-primary text-on-primary shadow-lg shadow-primary/20" 
                    : "border-2 border-primary text-primary hover:bg-primary/5"
                }`}
              >
                {plan.buttonText}
              </motion.button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
