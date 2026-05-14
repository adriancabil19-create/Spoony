import { createBrowserRouter } from "react-router";
import { RootLayout } from "./components/RootLayout";
import { Home } from "./components/Home";
import { Explore } from "./components/Explore";
import { Booking } from "./components/Booking";
import { Dashboard } from "./components/Dashboard";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: RootLayout,
    children: [
      { index: true, Component: Home },
      { path: "explore", Component: Explore },
      { path: "booking", Component: Booking },
      { path: "dashboard", Component: Dashboard },
    ],
  },
]);
