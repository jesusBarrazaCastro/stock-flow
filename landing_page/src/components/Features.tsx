import { Camera, Mic, BarChart3 } from "lucide-react";

const features = [
  {
    icon: Camera,
    title: "Registra con una foto",
    description: "Nuestra IA reconoce tus productos y facturas con solo apuntar la cámara. Olvida el teclado.",
    color: "text-tertiary",
    bgColor: "bg-tertiary/10"
  },
  {
    icon: Mic,
    title: "Consulta con tu voz",
    description: '"¿Cuántos bultos de harina quedan?" Pregunta y obtén respuestas al instante sin soltar tus herramientas.',
    color: "text-primary",
    bgColor: "bg-primary/10"
  },
  {
    icon: BarChart3,
    title: "Reportes automáticos",
    description: "Visualiza tendencias y salud de tu stock con gráficos diseñados para ser entendidos de un vistazo.",
    color: "text-on-primary-fixed-variant",
    bgColor: "bg-primary-container/20"
  }
];

export default function Features() {
  return (
    <section id="features" className="bg-surface px-8 py-24">
      <div className="mx-auto max-w-7xl">
        <div className="grid grid-cols-1 gap-16 lg:grid-cols-3">
          {features.map((feature, index) => (
            <div key={index} className="flex flex-col items-start gap-6">
              <div className={`rounded-full p-4 ${feature.bgColor}`}>
                <feature.icon className={`h-10 w-10 ${feature.color}`} />
              </div>
              <h3 className="font-headline text-3xl font-bold">{feature.title}</h3>
              <p className="text-lg leading-relaxed text-on-surface-variant">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
