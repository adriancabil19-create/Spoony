import { Outlet, Link, useLocation } from "react-router";
import { Compass, Map, Calendar, User, Menu, X } from "lucide-react";
import { useState } from "react";

export function RootLayout() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const location = useLocation();

  const navItems = [
    { name: "Home", path: "/", icon: Compass },
    { name: "Explore", path: "/explore", icon: Map },
    { name: "Bookings", path: "/booking", icon: Calendar },
    { name: "Dashboard", path: "/dashboard", icon: User },
  ];

  return (
    <div className="min-h-screen bg-neutral-50 font-sans text-neutral-900">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-white/80 backdrop-blur-md border-b border-neutral-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Link to="/" className="flex flex-shrink-0 items-center gap-2">
                <Compass className="h-8 w-8 text-[#00BCD4]" />
                <span className="font-bold text-xl tracking-tight text-[#006994]">
                  Spoony<span className="text-[#FF7F50]">Travel</span>
                </span>
              </Link>
            </div>

            {/* Desktop Navigation */}
            <div className="hidden sm:flex sm:items-center sm:space-x-8">
              {navItems.map((item) => {
                const isActive = location.pathname === item.path;
                return (
                  <Link
                    key={item.name}
                    to={item.path}
                    className={`inline-flex items-center px-1 pt-1 text-sm font-medium transition-colors ${
                      isActive
                        ? "text-[#00BCD4] border-b-2 border-[#00BCD4]"
                        : "text-neutral-500 hover:text-[#006994] hover:border-b-2 hover:border-[#006994]"
                    }`}
                  >
                    {item.name}
                  </Link>
                );
              })}
              <button className="bg-[#00BCD4] hover:bg-[#009eb3] text-white px-4 py-2 rounded-full font-medium transition-colors">
                Sign In
              </button>
            </div>

            {/* Mobile menu button */}
            <div className="flex items-center sm:hidden">
              <button
                onClick={() => setIsMenuOpen(!isMenuOpen)}
                className="inline-flex items-center justify-center p-2 rounded-md text-neutral-400 hover:text-neutral-500 hover:bg-neutral-100"
              >
                {isMenuOpen ? (
                  <X className="block h-6 w-6" />
                ) : (
                  <Menu className="block h-6 w-6" />
                )}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <div className="sm:hidden bg-white border-t border-neutral-200">
            <div className="pt-2 pb-3 space-y-1">
              {navItems.map((item) => {
                const isActive = location.pathname === item.path;
                return (
                  <Link
                    key={item.name}
                    to={item.path}
                    className={`flex items-center gap-3 px-4 py-3 text-base font-medium ${
                      isActive
                        ? "bg-[#E0F7FA] text-[#00BCD4] border-l-4 border-[#00BCD4]"
                        : "text-neutral-600 hover:bg-neutral-50 hover:text-[#006994]"
                    }`}
                    onClick={() => setIsMenuOpen(false)}
                  >
                    <item.icon className="h-5 w-5" />
                    {item.name}
                  </Link>
                );
              })}
              <div className="px-4 py-3">
                <button className="w-full bg-[#00BCD4] text-white px-4 py-2 rounded-full font-medium">
                  Sign In
                </button>
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main className="pt-16 min-h-[calc(100vh-64px)]">
        <Outlet />
      </main>

      {/* Footer */}
      <footer className="bg-[#006994] text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center gap-2 mb-4">
                <Compass className="h-8 w-8 text-[#00BCD4]" />
                <span className="font-bold text-xl tracking-tight">
                  Spoony<span className="text-[#FF7F50]">Travel</span>
                </span>
              </div>
              <p className="text-[#E0F7FA] max-w-sm mb-6">
                Your premium gateway to the most beautiful destinations in Cebu, Philippines. Experience world-class booking and seamless travel.
              </p>
            </div>
            <div>
              <h3 className="font-semibold text-lg mb-4 text-[#FF7F50]">Destinations</h3>
              <ul className="space-y-2 text-[#E0F7FA]">
                <li><Link to="/explore">Cebu City</Link></li>
                <li><Link to="/explore">South Cebu</Link></li>
                <li><Link to="/explore">North Cebu</Link></li>
                <li><Link to="/explore">Bohol Side Tours</Link></li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold text-lg mb-4 text-[#FF7F50]">Support</h3>
              <ul className="space-y-2 text-[#E0F7FA]">
                <li><a href="#">Contact Us</a></li>
                <li><a href="#">FAQs</a></li>
                <li><a href="#">Privacy Policy</a></li>
                <li><a href="#">Terms of Service</a></li>
              </ul>
            </div>
          </div>
          <div className="mt-12 pt-8 border-t border-[#00BCD4]/30 text-center text-[#E0F7FA]">
            <p>&copy; 2026 Spoony Travel and Tours. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
