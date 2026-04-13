import { LayoutGrid, GraduationCap, AlertCircle } from "lucide-react";

const problems = [
  {
    icon: LayoutGrid,
    title: "Rigidez Operativa",
    description: '"Los sistemas actuales son cuadrados y lentos. No se adaptan al ritmo real de tu negocio."'
  },
  {
    icon: GraduationCap,
    title: "Alta Curva de Aprendizaje",
    description: '"Demasiados manuales. Necesitas algo que tus empleados entiendan en 5 minutos."'
  },
  {
    icon: AlertCircle,
    title: "Errores Humanos",
    description: '"Capturas manuales que terminan en descuadres. Dinero perdido que no ves."'
  }
];

export default function Problem() {
  return (
    <section className="bg-surface-container-low px-8 py-24">
      <div className="mx-auto max-w-7xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-headline text-4xl font-bold text-on-surface md:text-5xl">
            ¿Por qué es tan difícil gestionar el stock?
          </h2>
          <div className="mx-auto h-1 w-24 rounded-full bg-primary"></div>
        </div>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-3">
          {problems.map((item, index) => (
            <div 
              key={index}
              className="rounded-2xl bg-surface-container-lowest p-10 transition-all hover:scale-[1.02]"
            >
              <div className="mb-6 flex h-14 w-14 items-center justify-center rounded-xl bg-primary-container/20">
                <item.icon className="h-8 w-8 text-primary" />
              </div>
              <h3 className="mb-4 font-headline text-2xl font-bold">{item.title}</h3>
              <p className="italic leading-relaxed text-on-surface-variant">
                {item.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
