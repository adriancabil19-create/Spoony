import { Link } from "react-router";
import { motion } from "motion/react";
import { MapPin, Calendar, Star, Navigation, ArrowRight, ShieldCheck, Clock, Palmtree } from "lucide-react";

const popularSpots = [
  {
    id: "spot-1",
    name: "Kawasan Falls",
    location: "Badian, South Cebu",
    image: "https://images.unsplash.com/photo-1620658927695-c33df6fb8130?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlcmZhbGwlMjBibHVlJTIwbGFnb29ufGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.9,
    reviews: 1240,
    price: "₱500",
  },
  {
    id: "spot-2",
    name: "Sirao Garden",
    location: "Cebu City",
    image: "https://images.unsplash.com/photo-1778477501822-d4236715cd96?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmbG93ZXIlMjBnYXJkZW4lMjB2aWV3fGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.8,
    reviews: 890,
    price: "₱100",
  },
  {
    id: "spot-3",
    name: "Chocolate Hills",
    location: "Bohol Side Tour",
    image: "https://images.unsplash.com/photo-1476988186444-a7189cf07b3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaG9jb2xhdGUlMjBoaWxscyUyMGJvaG9sfGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.9,
    reviews: 2100,
    price: "₱1,000",
  },
  {
    id: "spot-4",
    name: "Temple of Leah",
    location: "Cebu City",
    image: "https://images.unsplash.com/photo-1770462957658-313131728014?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZW1wbGUlMjB2aWV3JTIwYXJjaGl0ZWN0dXJlfGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.7,
    reviews: 1540,
    price: "₱150",
  },
];

export function Home() {
  return (
    <div className="flex flex-col w-full">
      {/* Hero Section */}
      <section className="relative h-[85vh] min-h-[600px] w-full flex items-center justify-center overflow-hidden">
        <div className="absolute inset-0 w-full h-full">
          <img
            src="https://images.unsplash.com/photo-1695051702427-1c24ce3682e7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0cm9waWNhbCUyMGJlYWNoJTIwcGhpbGlwcGluZXN8ZW58MXx8fHwxNzc4Nzg0MDgxfDA&ixlib=rb-4.1.0&q=80&w=1080"
            alt="Cebu Tropical Beach"
            className="w-full h-full object-cover object-center"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-[#006994]/80 to-transparent"></div>
          <div className="absolute inset-0 bg-black/20"></div>
        </div>

        <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full text-white">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="max-w-2xl"
          >
            <span className="inline-block py-1 px-3 rounded-full bg-[#00BCD4]/20 backdrop-blur-md border border-[#00BCD4]/50 text-[#E0F7FA] text-sm font-semibold mb-6">
              Premium Cebu Travel Experience
            </span>
            <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-6 leading-tight">
              Discover the <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#00BCD4] to-[#50C878]">
                Magic of Cebu
              </span>
            </h1>
            <p className="text-lg md:text-xl text-neutral-200 mb-10 font-light max-w-xl">
              From the deep blue of Kawasan Falls to the peaks of Osmeña, book your dream itinerary with real-time distance tracking and seamless reservations.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4">
              <Link
                to="/explore"
                className="inline-flex items-center justify-center px-8 py-4 text-base font-bold rounded-full text-white bg-gradient-to-r from-[#00BCD4] to-[#006994] hover:shadow-lg hover:shadow-[#00BCD4]/30 transition-all duration-300 transform hover:-translate-y-1"
              >
                Explore Destinations
                <ArrowRight className="ml-2 h-5 w-5" />
              </Link>
              <Link
                to="/booking"
                className="inline-flex items-center justify-center px-8 py-4 text-base font-bold rounded-full text-white bg-white/10 backdrop-blur-md border border-white/30 hover:bg-white/20 transition-all duration-300"
              >
                Plan Itinerary
              </Link>
            </div>
          </motion.div>
        </div>

        {/* Floating Search Bar */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="absolute -bottom-8 left-0 right-0 max-w-4xl mx-auto px-4 z-20"
        >
          <div className="bg-white rounded-2xl shadow-xl shadow-[#006994]/10 p-4 border border-neutral-100 flex flex-col md:flex-row gap-4 items-center">
            <div className="flex-1 w-full flex items-center gap-3 px-4 py-3 bg-neutral-50 rounded-xl border border-neutral-200 focus-within:border-[#00BCD4] focus-within:ring-1 focus-within:ring-[#00BCD4] transition-all">
              <MapPin className="text-[#FF7F50] h-5 w-5" />
              <input
                type="text"
                placeholder="Where to in Cebu?"
                className="bg-transparent border-none focus:outline-none w-full text-neutral-800 placeholder-neutral-400"
              />
            </div>
            <div className="flex-1 w-full flex items-center gap-3 px-4 py-3 bg-neutral-50 rounded-xl border border-neutral-200 focus-within:border-[#00BCD4] focus-within:ring-1 focus-within:ring-[#00BCD4] transition-all">
              <Calendar className="text-[#FF7F50] h-5 w-5" />
              <input
                type="date"
                className="bg-transparent border-none focus:outline-none w-full text-neutral-800"
              />
            </div>
            <button className="w-full md:w-auto px-8 py-3 bg-[#FF7F50] hover:bg-[#ff6a33] text-white font-bold rounded-xl transition-colors shadow-md shadow-[#FF7F50]/20">
              Search
            </button>
          </div>
        </motion.div>
      </section>

      {/* spacer for the floating search bar */}
      <div className="h-24"></div>

      {/* Popular Destinations */}
      <section className="py-20 bg-neutral-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-end mb-12">
            <div>
              <h2 className="text-3xl md:text-4xl font-bold text-[#006994] mb-4">
                Popular Destinations
              </h2>
              <p className="text-neutral-500 max-w-2xl text-lg">
                Discover the most highly-rated tourist spots across Cebu, curated just for you.
              </p>
            </div>
            <Link
              to="/explore"
              className="hidden md:flex items-center gap-2 text-[#00BCD4] font-semibold hover:text-[#009eb3] transition-colors"
            >
              View All <ArrowRight className="h-4 w-4" />
            </Link>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            {popularSpots.map((spot, index) => (
              <motion.div
                key={spot.id}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="bg-white rounded-3xl overflow-hidden shadow-lg shadow-neutral-200/50 hover:shadow-xl hover:-translate-y-2 transition-all duration-300 group"
              >
                <div className="relative h-64 overflow-hidden">
                  <img
                    src={spot.image}
                    alt={spot.name}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                  />
                  <div className="absolute top-4 right-4 bg-white/90 backdrop-blur-sm px-3 py-1 rounded-full flex items-center gap-1 shadow-sm">
                    <Star className="h-4 w-4 text-[#FF7F50] fill-[#FF7F50]" />
                    <span className="text-sm font-bold text-neutral-800">{spot.rating}</span>
                  </div>
                </div>
                <div className="p-6">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-xl font-bold text-[#006994] group-hover:text-[#00BCD4] transition-colors">
                      {spot.name}
                    </h3>
                  </div>
                  <div className="flex items-center gap-2 text-neutral-500 text-sm mb-4">
                    <MapPin className="h-4 w-4" />
                    <span>{spot.location}</span>
                  </div>
                  <div className="pt-4 border-t border-neutral-100 flex items-center justify-between">
                    <div>
                      <p className="text-xs text-neutral-400">Starting from</p>
                      <p className="text-lg font-bold text-[#50C878]">{spot.price}</p>
                    </div>
                    <Link
                      to={`/booking?spot=${spot.id}`}
                      className="px-4 py-2 bg-neutral-100 hover:bg-[#00BCD4] hover:text-white text-[#006994] rounded-lg font-semibold text-sm transition-colors"
                    >
                      Book Now
                    </Link>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
          
          <div className="mt-8 flex justify-center md:hidden">
            <Link
              to="/explore"
              className="flex items-center gap-2 text-[#00BCD4] font-semibold bg-[#E0F7FA] px-6 py-3 rounded-full"
            >
              View All Destinations <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-24 bg-white relative overflow-hidden">
        {/* Decorative background elements */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-[#E0F7FA] rounded-full blur-3xl opacity-50 -translate-y-1/2 translate-x-1/2"></div>
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-[#FF7F50]/10 rounded-full blur-3xl opacity-50 translate-y-1/2 -translate-x-1/2"></div>
        
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-3xl md:text-5xl font-bold text-[#006994] mb-6">
              Why Book With Us?
            </h2>
            <p className="text-neutral-500 text-lg">
              Experience the smartest way to travel across Cebu. Our premium platform ensures your journey is seamless from planning to memories.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-10">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="bg-white p-8 rounded-3xl shadow-lg shadow-neutral-100 border border-neutral-50 text-center hover:shadow-xl transition-shadow"
            >
              <div className="w-16 h-16 mx-auto bg-[#E0F7FA] rounded-2xl flex items-center justify-center mb-6 text-[#00BCD4]">
                <Navigation className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-bold text-neutral-800 mb-4">Smart Itinerary & Routing</h3>
              <p className="text-neutral-500 leading-relaxed">
                Dynamically calculate travel distances and estimated times between spots. Optimize your route to maximize your vacation time.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 }}
              className="bg-white p-8 rounded-3xl shadow-lg shadow-neutral-100 border border-neutral-50 text-center hover:shadow-xl transition-shadow"
            >
              <div className="w-16 h-16 mx-auto bg-[#FF7F50]/10 rounded-2xl flex items-center justify-center mb-6 text-[#FF7F50]">
                <ShieldCheck className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-bold text-neutral-800 mb-4">Secure Premium Booking</h3>
              <p className="text-neutral-500 leading-relaxed">
                Enjoy peace of mind with our secure payment gateways, verified local guides, and 24/7 dedicated support team.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.2 }}
              className="bg-white p-8 rounded-3xl shadow-lg shadow-neutral-100 border border-neutral-50 text-center hover:shadow-xl transition-shadow"
            >
              <div className="w-16 h-16 mx-auto bg-[#50C878]/10 rounded-2xl flex items-center justify-center mb-6 text-[#50C878]">
                <Palmtree className="h-8 w-8" />
              </div>
              <h3 className="text-xl font-bold text-neutral-800 mb-4">Curated Local Experiences</h3>
              <p className="text-neutral-500 leading-relaxed">
                Discover hidden gems and authentic local spots across North, South, and Central Cebu carefully selected by locals.
              </p>
            </motion.div>
          </div>
        </div>
      </section>
    </div>
  );
}
