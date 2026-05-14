import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { useSearchParams } from "react-router";
import { Check, ChevronRight, MapPin, Calendar as CalendarIcon, Users, CreditCard, Route, Clock, ChevronLeft, Bed, Car, ArrowRightCircle } from "lucide-react";

// Mock Data
const availableSpots = [
  { id: "spot-1", name: "Kawasan Falls", price: 500, region: "South Cebu" },
  { id: "spot-2", name: "Oslob Whale Shark", price: 1000, region: "South Cebu" },
  { id: "spot-3", name: "Magellan's Cross", price: 0, region: "Cebu City" },
  { id: "spot-4", name: "Sirao Garden", price: 100, region: "Cebu City" },
  { id: "spot-5", name: "Bantayan Island", price: 1500, region: "North Cebu" },
  { id: "spot-6", name: "Chocolate Hills", price: 1000, region: "Bohol" },
  { id: "spot-7", name: "Moalboal Sardine Run", price: 500, region: "South Cebu" },
  { id: "spot-8", name: "Temple of Leah", price: 150, region: "Cebu City" },
  { id: "spot-9", name: "Tumalog Falls", price: 50, region: "South Cebu" },
  { id: "spot-10", name: "Taoist Temple", price: 0, region: "Cebu City" },
  { id: "spot-11", name: "Sumilon Island", price: 1000, region: "South Cebu" },
  { id: "spot-12", name: "Fort San Pedro", price: 30, region: "Cebu City" },
  { id: "spot-13", name: "Malapascua Island", price: 1200, region: "North Cebu" },
  { id: "spot-14", name: "Tarsier Sanctuary", price: 150, region: "Bohol" },
];

const accommodations = [
  { id: "acc-1", name: "Budget Inn", price: 800, type: "Budget" },
  { id: "acc-2", name: "Standard Hotel", price: 1500, type: "Standard" },
  { id: "acc-3", name: "Premium Resort", price: 3000, type: "Premium" },
  { id: "acc-4", name: "Luxury Villa", price: 6000, type: "Luxury" },
];

const transports = [
  { id: "tr-1", name: "Shared Van", price: 300 },
  { id: "tr-2", name: "Private Sedan", price: 1500 },
  { id: "tr-3", name: "Private SUV", price: 2500 },
];

const steps = [
  { id: 1, name: "Details", icon: CalendarIcon },
  { id: 2, name: "Itinerary", icon: Route },
  { id: 3, name: "Extras", icon: Bed },
  { id: 4, name: "Payment", icon: CreditCard },
];

export function Booking() {
  const [searchParams] = useSearchParams();
  const initialSpot = searchParams.get("spot");

  const [currentStep, setCurrentStep] = useState(1);
  const [selectedSpots, setSelectedSpots] = useState<string[]>(initialSpot ? [initialSpot] : []);
  const [guests, setGuests] = useState(2);
  const [dates, setDates] = useState({ start: "", end: "" });
  const [selectedAccommodation, setSelectedAccommodation] = useState("acc-2");
  const [selectedTransport, setSelectedTransport] = useState("tr-2");
  const [isProcessing, setIsProcessing] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  // Derived values
  const spotsDetails = selectedSpots.map(id => availableSpots.find(s => s.id === id)!).filter(Boolean);
  const spotsTotal = spotsDetails.reduce((sum, spot) => sum + spot.price, 0) * guests;
  const accDetails = accommodations.find(a => a.id === selectedAccommodation);
  const trDetails = transports.find(t => t.id === selectedTransport);
  const accTotal = (accDetails?.price || 0) * guests; // Simplification
  const trTotal = trDetails?.price || 0;
  
  const grandTotal = spotsTotal + accTotal + trTotal;

  // Mock distance calculation
  const totalDistance = selectedSpots.length > 1 ? selectedSpots.length * 25.5 : 0;
  const totalTimeHours = selectedSpots.length > 1 ? selectedSpots.length * 1.5 : 0;

  const handleNext = () => {
    if (currentStep < 4) setCurrentStep(currentStep + 1);
  };

  const handleBack = () => {
    if (currentStep > 1) setCurrentStep(currentStep - 1);
  };

  const handleToggleSpot = (id: string) => {
    setSelectedSpots(prev => 
      prev.includes(id) ? prev.filter(s => s !== id) : [...prev, id]
    );
  };

  const handleCheckout = () => {
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      setIsSuccess(true);
    }, 2000);
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-neutral-50 py-20 flex items-center justify-center">
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white p-10 rounded-3xl shadow-xl max-w-lg text-center"
        >
          <div className="w-20 h-20 bg-[#50C878]/20 text-[#50C878] rounded-full flex items-center justify-center mx-auto mb-6">
            <Check className="h-10 w-10" />
          </div>
          <h2 className="text-3xl font-bold text-[#006994] mb-4">Booking Confirmed!</h2>
          <p className="text-neutral-500 mb-8">
            Your Cebu adventure is set. We've sent a confirmation email with your detailed itinerary and QR code tickets.
          </p>
          <div className="bg-[#E0F7FA] p-6 rounded-2xl mb-8 text-left">
            <p className="text-sm text-[#006994] font-semibold mb-2">Booking Reference</p>
            <p className="font-mono text-2xl font-bold text-[#00BCD4] tracking-widest">CEB-88X9Z</p>
          </div>
          <button 
            onClick={() => window.location.href = '/dashboard'}
            className="w-full py-4 bg-[#00BCD4] hover:bg-[#009eb3] text-white rounded-xl font-bold text-lg transition-colors shadow-lg shadow-[#00BCD4]/30"
          >
            Go to Dashboard
          </button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-neutral-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-5xl mx-auto">
        
        {/* Header & Progress */}
        <div className="mb-10 text-center">
          <h1 className="text-4xl font-bold text-[#006994] mb-4">Plan Your Adventure</h1>
          <p className="text-neutral-500">Customize your itinerary and book instantly.</p>
        </div>

        <div className="flex justify-center mb-12">
          <div className="flex items-center w-full max-w-3xl">
            {steps.map((step, index) => (
              <div key={step.id} className="flex flex-col items-center relative flex-1">
                <div 
                  className={`w-12 h-12 rounded-full flex items-center justify-center z-10 font-bold transition-all duration-300 ${
                    currentStep >= step.id 
                      ? "bg-[#00BCD4] text-white shadow-lg shadow-[#00BCD4]/40 scale-110" 
                      : "bg-white text-neutral-400 border-2 border-neutral-200"
                  }`}
                >
                  <step.icon className="h-5 w-5" />
                </div>
                <div className={`mt-3 text-sm font-semibold ${currentStep >= step.id ? "text-[#00BCD4]" : "text-neutral-400"}`}>
                  {step.name}
                </div>
                {index < steps.length - 1 && (
                  <div className={`absolute top-6 left-[50%] right-[-50%] h-1 -z-0 transition-colors duration-300 ${
                    currentStep > step.id ? "bg-[#00BCD4]" : "bg-neutral-200"
                  }`} />
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-8">
          
          {/* Main Form Area */}
          <div className="flex-1 bg-white rounded-3xl shadow-sm border border-neutral-200 p-6 md:p-8 min-h-[500px]">
            <AnimatePresence mode="wait">
              
              {/* STEP 1: Details */}
              {currentStep === 1 && (
                <motion.div
                  key="step1"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-6"
                >
                  <h2 className="text-2xl font-bold text-neutral-800 mb-6">When and Who?</h2>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-sm font-semibold text-neutral-600">Start Date</label>
                      <div className="relative">
                        <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-[#00BCD4]" />
                        <input 
                          type="date" 
                          value={dates.start}
                          onChange={(e) => setDates({...dates, start: e.target.value})}
                          className="w-full pl-10 pr-4 py-3 bg-neutral-50 border border-neutral-200 rounded-xl focus:ring-2 focus:ring-[#00BCD4] focus:border-transparent transition-all outline-none" 
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-semibold text-neutral-600">End Date</label>
                      <div className="relative">
                        <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-[#00BCD4]" />
                        <input 
                          type="date" 
                          value={dates.end}
                          onChange={(e) => setDates({...dates, end: e.target.value})}
                          className="w-full pl-10 pr-4 py-3 bg-neutral-50 border border-neutral-200 rounded-xl focus:ring-2 focus:ring-[#00BCD4] focus:border-transparent transition-all outline-none" 
                        />
                      </div>
                    </div>
                  </div>

                  <div className="space-y-2 mt-6">
                    <label className="text-sm font-semibold text-neutral-600">Number of Guests</label>
                    <div className="flex items-center gap-4 bg-neutral-50 border border-neutral-200 rounded-xl p-2 w-max">
                      <button 
                        onClick={() => setGuests(Math.max(1, guests - 1))}
                        className="w-10 h-10 rounded-lg bg-white shadow-sm flex items-center justify-center text-[#006994] hover:bg-[#E0F7FA] transition-colors"
                      >
                        -
                      </button>
                      <span className="font-bold text-lg w-8 text-center">{guests}</span>
                      <button 
                        onClick={() => setGuests(guests + 1)}
                        className="w-10 h-10 rounded-lg bg-[#00BCD4] text-white shadow-sm flex items-center justify-center hover:bg-[#009eb3] transition-colors"
                      >
                        +
                      </button>
                    </div>
                  </div>
                </motion.div>
              )}

              {/* STEP 2: Itinerary */}
              {currentStep === 2 && (
                <motion.div
                  key="step2"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-6"
                >
                  <div className="flex justify-between items-center mb-6">
                    <h2 className="text-2xl font-bold text-neutral-800">Select Destinations</h2>
                    <span className="text-sm bg-[#E0F7FA] text-[#006994] px-3 py-1 rounded-full font-semibold">
                      {selectedSpots.length} Selected
                    </span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                    {availableSpots.map((spot) => (
                      <div 
                        key={spot.id}
                        onClick={() => handleToggleSpot(spot.id)}
                        className={`cursor-pointer p-4 rounded-2xl border-2 transition-all duration-200 ${
                          selectedSpots.includes(spot.id) 
                            ? "border-[#00BCD4] bg-[#E0F7FA]/30 shadow-md" 
                            : "border-neutral-100 hover:border-neutral-200 bg-white"
                        }`}
                      >
                        <div className="flex justify-between items-start mb-2">
                          <h3 className="font-bold text-neutral-800">{spot.name}</h3>
                          <div className={`w-6 h-6 rounded-full flex items-center justify-center ${
                            selectedSpots.includes(spot.id) ? "bg-[#00BCD4] text-white" : "border-2 border-neutral-300"
                          }`}>
                            {selectedSpots.includes(spot.id) && <Check className="h-4 w-4" />}
                          </div>
                        </div>
                        <p className="text-xs text-neutral-500 flex items-center gap-1 mb-3">
                          <MapPin className="h-3 w-3" /> {spot.region}
                        </p>
                        <p className="font-bold text-[#50C878]">₱{spot.price.toLocaleString()}</p>
                      </div>
                    ))}
                  </div>

                  {/* Smart Distance Calculator Preview */}
                  {selectedSpots.length > 1 && (
                    <div className="mt-6 bg-[#006994] text-white rounded-2xl p-5 shadow-lg shadow-[#006994]/20 flex flex-col sm:flex-row justify-between items-center gap-4">
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                          <Route className="h-6 w-6 text-[#00BCD4]" />
                        </div>
                        <div>
                          <p className="text-sm text-[#E0F7FA] font-medium">Estimated Travel Distance</p>
                          <p className="text-2xl font-bold">{totalDistance} KM</p>
                        </div>
                      </div>
                      <div className="h-10 w-px bg-white/20 hidden sm:block"></div>
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                          <Clock className="h-6 w-6 text-[#FF7F50]" />
                        </div>
                        <div>
                          <p className="text-sm text-[#E0F7FA] font-medium">Estimated Travel Time</p>
                          <p className="text-2xl font-bold">{totalTimeHours} Hours</p>
                        </div>
                      </div>
                    </div>
                  )}
                </motion.div>
              )}

              {/* STEP 3: Extras */}
              {currentStep === 3 && (
                <motion.div
                  key="step3"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-8"
                >
                  <div>
                    <h2 className="text-xl font-bold text-neutral-800 mb-4 flex items-center gap-2">
                      <Bed className="h-5 w-5 text-[#FF7F50]" /> Accommodation Type
                    </h2>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      {accommodations.map((acc) => (
                        <div 
                          key={acc.id}
                          onClick={() => setSelectedAccommodation(acc.id)}
                          className={`cursor-pointer p-4 rounded-2xl border-2 transition-all duration-200 ${
                            selectedAccommodation === acc.id 
                              ? "border-[#FF7F50] bg-[#FF7F50]/5 shadow-md" 
                              : "border-neutral-100 hover:border-neutral-200 bg-white"
                          }`}
                        >
                          <div className="flex justify-between items-center mb-1">
                            <h3 className="font-bold text-neutral-800">{acc.type}</h3>
                            {selectedAccommodation === acc.id && <Check className="h-5 w-5 text-[#FF7F50]" />}
                          </div>
                          <p className="text-sm text-neutral-500 mb-2">{acc.name}</p>
                          <p className="font-bold text-[#006994]">₱{acc.price.toLocaleString()} <span className="text-xs text-neutral-400 font-normal">/night/person</span></p>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h2 className="text-xl font-bold text-neutral-800 mb-4 flex items-center gap-2">
                      <Car className="h-5 w-5 text-[#00BCD4]" /> Transportation
                    </h2>
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                      {transports.map((tr) => (
                        <div 
                          key={tr.id}
                          onClick={() => setSelectedTransport(tr.id)}
                          className={`cursor-pointer p-4 rounded-2xl border-2 transition-all duration-200 ${
                            selectedTransport === tr.id 
                              ? "border-[#00BCD4] bg-[#E0F7FA]/30 shadow-md" 
                              : "border-neutral-100 hover:border-neutral-200 bg-white"
                          }`}
                        >
                          <div className="flex justify-between items-center mb-2">
                            <h3 className="font-bold text-neutral-800 text-sm">{tr.name}</h3>
                          </div>
                          <p className="font-bold text-[#50C878]">₱{tr.price.toLocaleString()} <span className="text-xs text-neutral-400 font-normal">/total</span></p>
                        </div>
                      ))}
                    </div>
                  </div>
                </motion.div>
              )}

              {/* STEP 4: Payment */}
              {currentStep === 4 && (
                <motion.div
                  key="step4"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-6"
                >
                  <h2 className="text-2xl font-bold text-neutral-800 mb-6">Payment Method</h2>
                  
                  <div className="space-y-4">
                    <label className="flex items-center gap-4 p-4 border-2 border-[#00BCD4] bg-[#E0F7FA]/20 rounded-2xl cursor-pointer">
                      <input type="radio" name="payment" defaultChecked className="w-5 h-5 text-[#00BCD4] focus:ring-[#00BCD4]" />
                      <div className="flex-1">
                        <h4 className="font-bold text-neutral-800">Credit / Debit Card</h4>
                        <p className="text-sm text-neutral-500">Secure payment via Stripe</p>
                      </div>
                      <CreditCard className="h-6 w-6 text-[#006994]" />
                    </label>
                    <label className="flex items-center gap-4 p-4 border-2 border-neutral-200 hover:border-neutral-300 rounded-2xl cursor-pointer transition-colors">
                      <input type="radio" name="payment" className="w-5 h-5 text-[#00BCD4] focus:ring-[#00BCD4]" />
                      <div className="flex-1">
                        <h4 className="font-bold text-neutral-800">GCash / Maya</h4>
                        <p className="text-sm text-neutral-500">E-Wallet</p>
                      </div>
                      <div className="font-bold text-[#0070BA]">e-Pay</div>
                    </label>
                  </div>

                  <div className="mt-8 space-y-4">
                    <div className="relative">
                      <input type="text" placeholder="Card Number" className="w-full px-4 py-3 bg-neutral-50 border border-neutral-200 rounded-xl focus:ring-2 focus:ring-[#00BCD4] focus:border-transparent transition-all outline-none" />
                      <CreditCard className="absolute right-4 top-3.5 h-5 w-5 text-neutral-400" />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <input type="text" placeholder="MM/YY" className="w-full px-4 py-3 bg-neutral-50 border border-neutral-200 rounded-xl focus:ring-2 focus:ring-[#00BCD4] focus:border-transparent transition-all outline-none" />
                      <input type="text" placeholder="CVC" className="w-full px-4 py-3 bg-neutral-50 border border-neutral-200 rounded-xl focus:ring-2 focus:ring-[#00BCD4] focus:border-transparent transition-all outline-none" />
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            {/* Navigation Buttons */}
            <div className="mt-10 pt-6 border-t border-neutral-100 flex justify-between items-center">
              <button
                onClick={handleBack}
                disabled={currentStep === 1}
                className={`flex items-center gap-2 px-6 py-3 rounded-xl font-bold transition-all ${
                  currentStep === 1 
                    ? "text-neutral-300 cursor-not-allowed" 
                    : "text-neutral-600 bg-neutral-100 hover:bg-neutral-200"
                }`}
              >
                <ChevronLeft className="h-5 w-5" /> Back
              </button>
              
              {currentStep < 4 ? (
                <button
                  onClick={handleNext}
                  className="flex items-center gap-2 px-8 py-3 bg-[#00BCD4] hover:bg-[#009eb3] text-white rounded-xl font-bold transition-all shadow-md shadow-[#00BCD4]/30"
                >
                  Next <ChevronRight className="h-5 w-5" />
                </button>
              ) : (
                <button
                  onClick={handleCheckout}
                  disabled={isProcessing}
                  className="flex items-center justify-center gap-2 px-8 py-3 bg-[#50C878] hover:bg-[#43a865] text-white rounded-xl font-bold transition-all shadow-md shadow-[#50C878]/30 min-w-[160px]"
                >
                  {isProcessing ? (
                    <motion.div 
                      animate={{ rotate: 360 }} 
                      transition={{ repeat: Infinity, duration: 1, ease: "linear" }}
                      className="w-5 h-5 border-2 border-white border-t-transparent rounded-full"
                    />
                  ) : (
                    <>Pay Now <Check className="h-5 w-5" /></>
                  )}
                </button>
              )}
            </div>
          </div>

          {/* Sidebar Summary */}
          <div className="w-full lg:w-96 bg-[#006994] rounded-3xl p-6 text-white shadow-xl shadow-[#006994]/20 h-max sticky top-24">
            <h3 className="text-xl font-bold mb-6 text-[#E0F7FA] border-b border-white/10 pb-4">Booking Summary</h3>
            
            <div className="space-y-6">
              <div className="flex items-start gap-3">
                <Users className="h-5 w-5 text-[#00BCD4] shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm text-white/70">Guests</p>
                  <p className="font-semibold">{guests} Person{guests > 1 ? 's' : ''}</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <CalendarIcon className="h-5 w-5 text-[#00BCD4] shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm text-white/70">Dates</p>
                  <p className="font-semibold text-sm">
                    {dates.start ? new Date(dates.start).toLocaleDateString() : 'Not selected'} - 
                    {dates.end ? new Date(dates.end).toLocaleDateString() : 'Not selected'}
                  </p>
                </div>
              </div>

              <div className="border-t border-white/10 pt-4">
                <p className="text-sm text-white/70 mb-3 flex items-center justify-between">
                  Destinations <span>₱{spotsTotal.toLocaleString()}</span>
                </p>
                <ul className="space-y-2 text-sm">
                  {spotsDetails.map(spot => (
                    <li key={spot.id} className="flex items-start gap-2 text-[#E0F7FA]">
                      <ArrowRightCircle className="h-4 w-4 shrink-0 mt-0.5 text-[#00BCD4]" />
                      <span>{spot.name} <span className="opacity-70 text-xs">x{guests}</span></span>
                    </li>
                  ))}
                  {spotsDetails.length === 0 && <li className="text-white/50 italic">No spots selected</li>}
                </ul>
              </div>

              <div className="border-t border-white/10 pt-4">
                <p className="text-sm text-white/70 mb-2 flex justify-between">
                  Accommodation <span>₱{accTotal.toLocaleString()}</span>
                </p>
                <p className="text-sm text-[#E0F7FA]">{accDetails?.name || 'None'}</p>
              </div>

              <div className="border-t border-white/10 pt-4">
                <p className="text-sm text-white/70 mb-2 flex justify-between">
                  Transportation <span>₱{trTotal.toLocaleString()}</span>
                </p>
                <p className="text-sm text-[#E0F7FA]">{trDetails?.name || 'None'}</p>
              </div>
            </div>

            <div className="mt-8 pt-6 border-t border-white/20">
              <div className="flex justify-between items-end mb-1">
                <p className="text-lg font-medium text-[#E0F7FA]">Total Amount</p>
                <p className="text-3xl font-extrabold text-[#50C878]">₱{grandTotal.toLocaleString()}</p>
              </div>
              <p className="text-xs text-white/50 text-right">Includes taxes & fees</p>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
