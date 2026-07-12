import type { UserProfile } from "@/types";

export const mockProfile: UserProfile = {
  id: "usr_001",
  name: "Arjun Krishnamurthy",
  email: "arjun.k@example.com",
  avatar: "AK",
  age: 34,
  occupation: "Software Engineer",
  healthCategory: "healthy",
  medicalConditions: [],
  location: {
    city: "Chennai",
    district: "Chennai",
    state: "Tamil Nadu",
    country: "India",
    lat: 13.0827,
    lng: 80.2707,
  },
  savedLocations: [
    {
      city: "Bengaluru",
      district: "Bangalore Urban",
      state: "Karnataka",
      country: "India",
      lat: 12.9716,
      lng: 77.5946,
    },
    {
      city: "Coimbatore",
      district: "Coimbatore",
      state: "Tamil Nadu",
      country: "India",
      lat: 11.0168,
      lng: 76.9558,
    },
  ],
  temperatureUnit: "celsius",
  notificationsEnabled: true,
  alertThreshold: "high",
  joinedDate: "2024-03-15T00:00:00Z",
};

export const healthCategories = [
  {
    id: "healthy",
    label: "Generally Healthy",
    description: "No major health conditions",
    icon: "💪",
  },
  {
    id: "vulnerable",
    label: "Vulnerable Individual",
    description: "Chronic illness, respiratory or cardiac conditions",
    icon: "❤️",
  },
  {
    id: "elderly",
    label: "Elderly (60+)",
    description: "Senior citizen with reduced heat tolerance",
    icon: "👴",
  },
  {
    id: "outdoor_worker",
    label: "Outdoor Worker",
    description: "Construction, delivery, agriculture",
    icon: "👷",
  },
];

export const activityStats = [
  { label: "Days Tracked", value: "127", icon: "📅" },
  { label: "Alerts Avoided", value: "43", icon: "🛡️" },
  { label: "Queries Asked", value: "89", icon: "💬" },
  { label: "Risk Score Avg", value: "62", icon: "📊" },
];
