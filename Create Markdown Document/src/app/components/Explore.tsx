import { useState } from "react";
import { Link } from "react-router";
import { motion } from "motion/react";
import { Search, MapPin, Star, Filter, Heart } from "lucide-react";

type Region = "All" | "Cebu City" | "South Cebu" | "North Cebu" | "Bohol";

const spots = [
  {
    id: "spot-1",
    name: "Kawasan Falls",
    region: "South Cebu",
    location: "Badian",
    image: "https://images.unsplash.com/photo-1620658927695-c33df6fb8130?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlcmZhbGwlMjBibHVlJTIwbGFnb29ufGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.9,
    price: "₱500",
    tags: ["Nature", "Adventure"],
  },
  {
    id: "spot-2",
    name: "Oslob Whale Shark",
    region: "South Cebu",
    location: "Oslob",
    image: "https://images.unsplash.com/photo-1540202404-b2979d19ed37?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxvc2xvYiUyMHdoYWxlJTIwc2hhcmt8ZW58MXx8fHwxNzc4Nzg0MTQwfDA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.8,
    price: "₱1,000",
    tags: ["Wildlife", "Ocean"],
  },
  {
    id: "spot-3",
    name: "Magellan's Cross",
    region: "Cebu City",
    location: "Downtown Cebu",
    image: "https://images.unsplash.com/photo-1549848314-6feb163cb2d4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWdlbGxhbiUyMGNyb3NzJTIwY2VidXxlbnwxfHx8fDE3Nzg3ODQxNDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.5,
    price: "Free",
    tags: ["History", "Culture"],
  },
  {
    id: "spot-4",
    name: "Sirao Garden",
    region: "Cebu City",
    location: "Busay",
    image: "https://images.unsplash.com/photo-1778477501822-d4236715cd96?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmbG93ZXIlMjBnYXJkZW4lMjB2aWV3fGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.7,
    price: "₱100",
    tags: ["Nature", "Photography"],
  },
  {
    id: "spot-5",
    name: "Bantayan Island",
    region: "North Cebu",
    location: "Bantayan",
    image: "https://images.unsplash.com/photo-1682246475305-3f7d7f494b3e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiYW50YXlhbiUyMGlzbGFuZCUyMGJlYWNofGVufDF8fHx8MTc3ODc4NDE0MXww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.9,
    price: "₱1,500",
    tags: ["Beach", "Relaxation"],
  },
  {
    id: "spot-6",
    name: "Chocolate Hills",
    region: "Bohol",
    location: "Carmen, Bohol",
    image: "https://images.unsplash.com/photo-1476988186444-a7189cf07b3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaG9jb2xhdGUlMjBoaWxscyUyMGJvaG9sfGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.8,
    price: "₱1,000",
    tags: ["Nature", "Iconic"],
  },
  {
    id: "spot-7",
    name: "Moalboal Sardine Run",
    region: "South Cebu",
    location: "Moalboal",
    image: "https://images.unsplash.com/photo-1574244104030-7ebb728e683c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2FsYm9hbCUyMHR1cnRsZXxlbnwxfHx8fDE3Nzg3ODQxNDF8MA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.9,
    price: "₱500",
    tags: ["Diving", "Wildlife"],
  },
  {
    id: "spot-8",
    name: "Temple of Leah",
    region: "Cebu City",
    location: "Busay",
    image: "https://images.unsplash.com/photo-1770462957658-313131728014?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZW1wbGUlMjB2aWV3JTIwYXJjaGl0ZWN0dXJlfGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.6,
    price: "₱150",
    tags: ["Architecture", "Views"],
  },
  {
    id: "spot-9",
    name: "Tumalog Falls",
    region: "South Cebu",
    location: "Oslob",
    image: "https://images.unsplash.com/photo-1586263426392-3b3e0748f618?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlcmZhbGwlMjB0dW1hbG9nJTIwY2VidXxlbnwxfHx8fDE3Nzg3ODQzOTV8MA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.7,
    price: "₱50",
    tags: ["Nature", "Waterfall"],
  },
  {
    id: "spot-10",
    name: "Taoist Temple",
    region: "Cebu City",
    location: "Lahug",
    image: "https://images.unsplash.com/photo-1507868162883-6b769c1a88c1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0YW9pc3QlMjB0ZW1wbGUlMjBhcmNoaXRlY3R1cmV8ZW58MXx8fHwxNzc4Nzg0Mzk1fDA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.5,
    price: "Free",
    tags: ["Culture", "Architecture"],
  },
  {
    id: "spot-11",
    name: "Sumilon Island",
    region: "South Cebu",
    location: "Oslob",
    image: "https://images.unsplash.com/photo-1713097137978-1fb8d45648b7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdW1pbG9uJTIwaXNsYW5kJTIwc2FuZGJhcnxlbnwxfHx8fDE3Nzg3ODQ0MDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.9,
    price: "₱1,000",
    tags: ["Beach", "Sandbar"],
  },
  {
    id: "spot-12",
    name: "Fort San Pedro",
    region: "Cebu City",
    location: "Plaza Independencia",
    image: "https://images.unsplash.com/photo-1751814584469-77f3d6252185?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmb3J0JTIwc2FuJTIwcGVkcm8lMjBjZWJ1fGVufDF8fHx8MTc3ODc4NDM5NXww&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.4,
    price: "₱30",
    tags: ["History", "Museum"],
  },
  {
    id: "spot-13",
    name: "Malapascua Island",
    region: "North Cebu",
    location: "Daanbantayan",
    image: "https://images.unsplash.com/photo-1636905568388-515fc8790dff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxhcGFzY3VhJTIwaXNsYW5kJTIwYmVhY2h8ZW58MXx8fHwxNzc4Nzg0Mzk1fDA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.8,
    price: "₱1,200",
    tags: ["Diving", "Beach"],
  },
  {
    id: "spot-14",
    name: "Tarsier Sanctuary",
    region: "Bohol",
    location: "Corella",
    image: "https://images.unsplash.com/photo-1567856764367-b2de2e573f71?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0YXJzaWVyJTIwbW9ua2V5JTIwYm9ob2x8ZW58MXx8fHwxNzc4Nzg0NDAwfDA&ixlib=rb-4.1.0&q=80&w=1080",
    rating: 4.8,
    price: "₱150",
    tags: ["Wildlife", "Nature"],
  },
];

const regions: Region[] = ["All", "Cebu City", "South Cebu", "North Cebu", "Bohol"];

export function Explore() {
  const [activeRegion, setActiveRegion] = useState<Region>("All");
  const [searchQuery, setSearchQuery] = useState("");

  const filteredSpots = spots.filter(
    (spot) =>
      (activeRegion === "All" || spot.region === activeRegion) &&
      spot.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="bg-neutral-50 min-h-screen py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Header Section */}
        <div className="mb-12 text-center max-w-2xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-[#006994] mb-4">
            Explore Destinations
          </h1>
          <p className="text-neutral-500 text-lg">
            From pristine beaches to mountain peaks, discover the wonders of Cebu and its neighboring islands.
          </p>
        </div>

        {/* Search & Filter Bar */}
        <div className="bg-white rounded-2xl shadow-sm border border-neutral-200 p-4 mb-10 flex flex-col lg:flex-row gap-4 justify-between items-center">
          <div className="flex w-full lg:w-96 items-center gap-3 px-4 py-3 bg-neutral-50 rounded-xl border border-neutral-200 focus-within:border-[#00BCD4] focus-within:ring-1 focus-within:ring-[#00BCD4] transition-all">
            <Search className="text-neutral-400 h-5 w-5" />
            <input
              type="text"
              placeholder="Search spots (e.g., Kawasan Falls)"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-transparent border-none focus:outline-none w-full text-neutral-800"
            />
          </div>

          <div className="flex flex-wrap gap-2 justify-center lg:justify-end">
            <div className="hidden lg:flex items-center text-neutral-400 mr-2">
              <Filter className="h-5 w-5" />
            </div>
            {regions.map((region) => (
              <button
                key={region}
                onClick={() => setActiveRegion(region)}
                className={`px-5 py-2.5 rounded-full text-sm font-semibold transition-all duration-200 ${
                  activeRegion === region
                    ? "bg-[#00BCD4] text-white shadow-md shadow-[#00BCD4]/20"
                    : "bg-neutral-100 text-neutral-600 hover:bg-neutral-200"
                }`}
              >
                {region}
              </button>
            ))}
          </div>
        </div>

        {/* Spots Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
          {filteredSpots.length > 0 ? (
            filteredSpots.map((spot, index) => (
              <motion.div
                key={spot.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.3, delay: index * 0.05 }}
                className="bg-white rounded-3xl overflow-hidden shadow-md shadow-neutral-200/50 hover:shadow-xl hover:-translate-y-2 transition-all duration-300 group flex flex-col"
              >
                <div className="relative h-56 overflow-hidden">
                  <img
                    src={spot.image}
                    alt={spot.name}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                  />
                  <div className="absolute top-4 left-4 bg-[#006994]/80 backdrop-blur-sm text-white px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide">
                    {spot.region}
                  </div>
                  <button className="absolute top-4 right-4 bg-white/80 backdrop-blur-sm p-2 rounded-full hover:bg-red-50 text-neutral-400 hover:text-red-500 transition-colors shadow-sm">
                    <Heart className="h-5 w-5" />
                  </button>
                </div>
                <div className="p-6 flex flex-col flex-1">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-xl font-bold text-neutral-800 group-hover:text-[#00BCD4] transition-colors leading-tight">
                      {spot.name}
                    </h3>
                  </div>
                  <div className="flex items-center gap-2 text-neutral-500 text-sm mb-4">
                    <MapPin className="h-4 w-4 shrink-0 text-[#FF7F50]" />
                    <span className="truncate">{spot.location}</span>
                  </div>
                  
                  <div className="flex flex-wrap gap-2 mb-6">
                    {spot.tags.map((tag) => (
                      <span key={tag} className="px-2.5 py-1 bg-neutral-100 text-neutral-600 text-xs rounded-md font-medium">
                        {tag}
                      </span>
                    ))}
                  </div>

                  <div className="mt-auto pt-4 border-t border-neutral-100 flex items-center justify-between">
                    <div>
                      <div className="flex items-center gap-1 mb-1">
                        <Star className="h-4 w-4 text-[#FF7F50] fill-[#FF7F50]" />
                        <span className="text-sm font-bold text-neutral-700">{spot.rating}</span>
                      </div>
                      <p className="text-lg font-bold text-[#50C878]">{spot.price}</p>
                    </div>
                    <Link
                      to={`/booking?spot=${spot.id}`}
                      className="px-5 py-2.5 bg-[#00BCD4] hover:bg-[#009eb3] text-white rounded-xl font-semibold text-sm transition-colors shadow-sm shadow-[#00BCD4]/30"
                    >
                      Add to Itinerary
                    </Link>
                  </div>
                </div>
              </motion.div>
            ))
          ) : (
            <div className="col-span-full py-20 text-center text-neutral-500">
              <MapPin className="h-16 w-16 mx-auto text-neutral-300 mb-4" />
              <h3 className="text-2xl font-semibold mb-2 text-neutral-700">No destinations found</h3>
              <p>Try adjusting your search or region filter.</p>
            </div>
          )}
        </div>

      </div>
    </div>
  );
}
