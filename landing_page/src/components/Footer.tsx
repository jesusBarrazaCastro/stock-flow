import { Package } from "lucide-react";

export default function Footer() {
  return (
    <footer className="bg-surface-container-high px-8 py-12">
      <div className="mx-auto grid max-w-7xl grid-cols-1 gap-12 md:grid-cols-3">
        <div className="space-y-6">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary shadow-lg shadow-primary/20">
              <Package className="h-8 w-8 text-on-primary" />
            </div>
            <div className="font-headline text-3xl font-bold text-primary">Stock Flow</div>
          </div>
          <p className="text-sm leading-relaxed text-on-surface-variant">
            © 2024 Stock Flow. Inteligencia Editorial para tu Inventario. Empoderando a las PyMEs de México con tecnología de punta y alma artesanal.
          </p>
          <div className="flex gap-4">
            <img 
              src="https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg" 
              alt="App Store" 
              className="h-10 cursor-pointer opacity-80 transition-opacity hover:opacity-100"
              referrerPolicy="no-referrer"
            />
            <img 
              src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" 
              alt="Google Play" 
              className="h-10 cursor-pointer opacity-80 transition-opacity hover:opacity-100"
              referrerPolicy="no-referrer"
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-8">
          <div className="space-y-4">
            <h5 className="font-bold text-primary">Compañía</h5>
            <nav className="flex flex-col gap-2">
              <a href="#" className="text-sm text-on-surface-variant hover:text-primary transition-colors">Sobre Nosotros</a>
              <a href="#" className="text-sm text-on-surface-variant hover:text-primary transition-colors">Blog</a>
              <a href="#" className="text-sm text-on-surface-variant hover:text-primary transition-colors">Carreras</a>
            </nav>
          </div>
          <div className="space-y-4">
            <h5 className="font-bold text-primary">Legal</h5>
            <nav className="flex flex-col gap-2">
              <a href="#" className="text-sm text-on-surface-variant hover:text-primary transition-colors">Privacy Policy</a>
              <a href="#" className="text-sm text-on-surface-variant hover:text-primary transition-colors">Terms of Service</a>
              <a href="#" className="text-sm text-on-surface-variant hover:text-primary transition-colors">Support</a>
            </nav>
          </div>
        </div>

        <div className="space-y-6">
          <h5 className="font-bold text-primary">Disponible en iOS y Android</h5>
          <p className="text-sm text-on-surface-variant">Suscríbete para recibir tips de gestión y noticias de lanzamientos.</p>
          <div className="flex gap-2">
            <input 
              type="email" 
              placeholder="Tu correo" 
              className="flex-1 rounded-lg border-none bg-surface-container-lowest px-4 py-2 text-sm focus:ring-2 focus:ring-primary"
            />
            <button className="rounded-lg bg-primary px-4 py-2 text-sm font-bold text-on-primary">Unirse</button>
          </div>
        </div>
      </div>
    </footer>
  );
}
