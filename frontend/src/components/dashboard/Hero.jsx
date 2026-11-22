export default function Hero({ title, subtitle, userName }) {
  // Get current time for dynamic greeting
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  };

  const displayName = userName || "Sales Manager";

  return (
    <div className="hero">
      <h1>{title || `${getGreeting()}, ${displayName} 👋`}</h1>
      <p>{subtitle || "Welcome back to FlowCRM AI. Monitor trial telemetry, manage pipeline velocity, and prioritize high-conversion customer opportunities."}</p>
    </div>
  );
}