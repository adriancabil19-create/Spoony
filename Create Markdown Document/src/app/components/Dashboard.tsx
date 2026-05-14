import { useState } from "react";
import { motion } from "motion/react";
import { User, Calendar, MapPin, Settings, LogOut, Clock, Star, Bell, CreditCard, ChevronRight } from "lucide-react";

export function Dashboard() {
  const [activeTab, setActiveTab] = useState("upcoming");

  return (
    <div className="min-h-screen bg-neutral-50 py-10 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row gap-8">
        
        {/* Sidebar */}
        <div className="w-full md:w-72 shrink-0">
          <div className="bg-white rounded-3xl p-6 shadow-sm border border-neutral-200 sticky top-24">
            <div className="flex flex-col items-center mb-8">
              <div className="w-24 h-24 rounded-full bg-[#00BCD4]/10 mb-4 overflow-hidden border-4 border-white shadow-md">
                <img 
                  src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZXxlbnwxfHx8fDE3Nzg3ODQ1MDB8MA&ixlib=rb-4.1.0&q=80&w=400" 
                  alt="User" 
                  className="w-full h-full object-cover"
                />
              </div>
              <h2 className="text-xl font-bold text-[#006994]">Juan Dela Cruz</h2>
              <p className="text-sm text-neutral-500">Premium Member</p>
            </div>

            <nav className="space-y-2">
              <button 
                onClick={() => setActiveTab("upcoming")}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-colors font-medium ${
                  activeTab === "upcoming" ? "bg-[#00BCD4] text-white shadow-md shadow-[#00BCD4]/20" : "text-neutral-600 hover:bg-neutral-50"
                }`}
              >
                <Calendar className="h-5 w-5" /> Upcoming Trips
              </button>
              <button 
                onClick={() => setActiveTab("history")}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-colors font-medium ${
                  activeTab === "history" ? "bg-[#00BCD4] text-white shadow-md shadow-[#00BCD4]/20" : "text-neutral-600 hover:bg-neutral-50"
                }`}
              >
                <Clock className="h-5 w-5" /> Booking History
              </button>
              <button 
                onClick={() => setActiveTab("favorites")}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-colors font-medium ${
                  activeTab === "favorites" ? "bg-[#00BCD4] text-white shadow-md shadow-[#00BCD4]/20" : "text-neutral-600 hover:bg-neutral-50"
                }`}
              >
                <Star className="h-5 w-5" /> Saved Spots
              </button>
              <button 
                onClick={() => setActiveTab("settings")}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-colors font-medium ${
                  activeTab === "settings" ? "bg-[#00BCD4] text-white shadow-md shadow-[#00BCD4]/20" : "text-neutral-600 hover:bg-neutral-50"
                }`}
              >
                <Settings className="h-5 w-5" /> Account Settings
              </button>
            </nav>

            <div className="mt-8 pt-6 border-t border-neutral-100">
              <button className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-red-500 hover:bg-red-50 font-medium transition-colors">
                <LogOut className="h-5 w-5" /> Sign Out
              </button>
            </div>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1">
          {activeTab === "upcoming" && (
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-6"
            >
              <div className="flex justify-between items-end mb-6">
                <div>
                  <h1 className="text-3xl font-bold text-[#006994]">Upcoming Trips</h1>
                  <p className="text-neutral-500 mt-1">Get ready for your next adventure.</p>
                </div>
              </div>

              {/* Booking Card */}
              <div className="bg-white rounded-3xl p-6 shadow-sm border border-neutral-200">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4 border-b border-neutral-100 pb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="bg-[#E0F7FA] text-[#00BCD4] text-xs font-bold px-2 py-1 rounded-md">CONFIRMED</span>
                      <span className="text-neutral-400 text-sm font-medium">Ref: CEB-88X9Z</span>
                    </div>
                    <h3 className="text-xl font-bold text-neutral-800">South Cebu Explorer</h3>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-extrabold text-[#50C878]">₱7,500</p>
                    <p className="text-sm text-neutral-500">Fully Paid via GCash</p>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                  <div className="flex items-start gap-3">
                    <Calendar className="h-5 w-5 text-[#FF7F50] shrink-0" />
                    <div>
                      <p className="text-sm text-neutral-500 font-medium">Dates</p>
                      <p className="font-semibold text-neutral-800">Oct 12 - Oct 14, 2026</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <User className="h-5 w-5 text-[#00BCD4] shrink-0" />
                    <div>
                      <p className="text-sm text-neutral-500 font-medium">Guests</p>
                      <p className="font-semibold text-neutral-800">2 Adults</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <MapPin className="h-5 w-5 text-[#50C878] shrink-0" />
                    <div>
                      <p className="text-sm text-neutral-500 font-medium">Destinations</p>
                      <p className="font-semibold text-neutral-800">Oslob, Kawasan, Moalboal</p>
                    </div>
                  </div>
                </div>

                <div className="flex gap-4">
                  <button className="flex-1 py-3 bg-[#006994] hover:bg-[#005275] text-white rounded-xl font-semibold transition-colors">
                    View Tickets (QR)
                  </button>
                  <button className="flex-1 py-3 bg-neutral-100 hover:bg-neutral-200 text-neutral-700 rounded-xl font-semibold transition-colors">
                    Download Itinerary
                  </button>
                </div>
              </div>
            </motion.div>
          )}

          {activeTab === "history" && (
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <h1 className="text-3xl font-bold text-[#006994] mb-6">Booking History</h1>
              <div className="bg-white rounded-3xl p-8 shadow-sm border border-neutral-200 text-center">
                <Clock className="h-16 w-16 text-neutral-300 mx-auto mb-4" />
                <h3 className="text-xl font-bold text-neutral-700 mb-2">No past trips yet</h3>
                <p className="text-neutral-500">Your past adventures will appear here.</p>
              </div>
            </motion.div>
          )}

          {activeTab === "favorites" && (
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <h1 className="text-3xl font-bold text-[#006994] mb-6">Saved Spots</h1>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                {/* Mock Favorite Card */}
                <div className="bg-white rounded-2xl overflow-hidden shadow-sm border border-neutral-200 flex flex-col">
                  <img src="https://images.unsplash.com/photo-1620658927695-c33df6fb8130?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlcmZhbGwlMjBibHVlJTIwbGFnb29ufGVufDF8fHx8MTc3ODc4NDEwMHww&ixlib=rb-4.1.0&q=80&w=1080" alt="Kawasan" className="h-40 w-full object-cover" />
                  <div className="p-4 flex-1 flex flex-col justify-between">
                    <div>
                      <h3 className="font-bold text-lg text-neutral-800">Kawasan Falls</h3>
                      <p className="text-sm text-neutral-500 flex items-center gap-1"><MapPin className="h-3 w-3" /> South Cebu</p>
                    </div>
                    <button className="mt-4 w-full py-2 bg-[#00BCD4] text-white rounded-lg text-sm font-semibold">Book Now</button>
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {activeTab === "settings" && (
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <h1 className="text-3xl font-bold text-[#006994] mb-6">Account Settings</h1>
              <div className="bg-white rounded-3xl p-6 shadow-sm border border-neutral-200 space-y-6">
                
                <div>
                  <h3 className="font-bold text-lg text-neutral-800 mb-4 border-b border-neutral-100 pb-2">Personal Information</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-1">
                      <label className="text-sm text-neutral-500 font-medium">Full Name</label>
                      <input type="text" defaultValue="Juan Dela Cruz" className="w-full px-4 py-2 bg-neutral-50 border border-neutral-200 rounded-lg" />
                    </div>
                    <div className="space-y-1">
                      <label className="text-sm text-neutral-500 font-medium">Email</label>
                      <input type="email" defaultValue="juan@example.com" className="w-full px-4 py-2 bg-neutral-50 border border-neutral-200 rounded-lg" />
                    </div>
                    <div className="space-y-1">
                      <label className="text-sm text-neutral-500 font-medium">Phone</label>
                      <input type="tel" defaultValue="+63 912 345 6789" className="w-full px-4 py-2 bg-neutral-50 border border-neutral-200 rounded-lg" />
                    </div>
                  </div>
                  <button className="mt-4 px-6 py-2 bg-[#006994] text-white rounded-lg font-medium text-sm">Save Changes</button>
                </div>

                <div className="pt-4">
                  <h3 className="font-bold text-lg text-neutral-800 mb-4 border-b border-neutral-100 pb-2">Preferences</h3>
                  <div className="space-y-4">
                    <label className="flex items-center justify-between cursor-pointer">
                      <div className="flex items-center gap-3">
                        <Bell className="h-5 w-5 text-neutral-400" />
                        <div>
                          <p className="font-medium text-neutral-800">Email Notifications</p>
                          <p className="text-xs text-neutral-500">Get updates about your bookings</p>
                        </div>
                      </div>
                      <input type="checkbox" defaultChecked className="toggle-checkbox w-10 h-5 bg-neutral-200 rounded-full appearance-none checked:bg-[#00BCD4] transition-colors relative cursor-pointer" />
                    </label>
                  </div>
                </div>

              </div>
            </motion.div>
          )}
        </div>

      </div>
    </div>
  );
}
