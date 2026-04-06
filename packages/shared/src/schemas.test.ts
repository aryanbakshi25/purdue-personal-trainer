import { describe, it, expect } from "vitest";
import {
  ScheduleBlock,
  UserProfile,
  WorkoutSplit,
  DailyPlan,
  ChatRequest,
  FacilityUsageItem,
} from "./schemas";

describe("ScheduleBlock", () => {
  it("validates a correct schedule block", () => {
    const result = ScheduleBlock.safeParse({
      id: "550e8400-e29b-41d4-a716-446655440000",
      title: "CS 252 Lecture",
      dayOfWeek: "monday",
      startTime: "09:30",
      endTime: "10:20",
      location: "LWSN B134",
      category: "class",
      isRecurring: true,
    });
    expect(result.success).toBe(true);
  });

  it("rejects invalid time format", () => {
    const result = ScheduleBlock.safeParse({
      id: "550e8400-e29b-41d4-a716-446655440000",
      title: "Gym",
      dayOfWeek: "monday",
      startTime: "9:30 AM",
      endTime: "10:20",
    });
    expect(result.success).toBe(false);
  });

  it("rejects empty title", () => {
    const result = ScheduleBlock.safeParse({
      id: "550e8400-e29b-41d4-a716-446655440000",
      title: "",
      dayOfWeek: "monday",
      startTime: "09:30",
      endTime: "10:20",
    });
    expect(result.success).toBe(false);
  });
});

describe("UserProfile", () => {
  it("validates a correct user profile", () => {
    const result = UserProfile.safeParse({
      uid: "abc123",
      displayName: "John Doe",
      email: "jdoe@purdue.edu",
      fitnessLevel: "intermediate",
      goals: ["Build muscle", "Improve cardio"],
      preferredFacilities: ["CoRec"],
      createdAt: "2025-01-15T10:00:00Z",
      updatedAt: "2025-01-15T10:00:00Z",
    });
    expect(result.success).toBe(true);
  });

  it("applies default fitness level", () => {
    const result = UserProfile.parse({
      uid: "abc123",
      displayName: "John Doe",
      email: "jdoe@purdue.edu",
      createdAt: "2025-01-15T10:00:00Z",
      updatedAt: "2025-01-15T10:00:00Z",
    });
    expect(result.fitnessLevel).toBe("beginner");
  });

  it("accepts athlete fitness level", () => {
    const result = UserProfile.safeParse({
      uid: "abc123",
      displayName: "Jane Doe",
      email: "jane@purdue.edu",
      fitnessLevel: "athlete",
      createdAt: "2025-01-15T10:00:00Z",
      updatedAt: "2025-01-15T10:00:00Z",
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.fitnessLevel).toBe("athlete");
    }
  });

  it("accepts valid workoutSplit", () => {
    const result = UserProfile.safeParse({
      uid: "abc123",
      displayName: "John Doe",
      email: "jdoe@purdue.edu",
      workoutSplit: "ppl",
      createdAt: "2025-01-15T10:00:00Z",
      updatedAt: "2025-01-15T10:00:00Z",
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.workoutSplit).toBe("ppl");
    }
  });

  it("allows omitted workoutSplit", () => {
    const result = UserProfile.safeParse({
      uid: "abc123",
      displayName: "John Doe",
      email: "jdoe@purdue.edu",
      createdAt: "2025-01-15T10:00:00Z",
      updatedAt: "2025-01-15T10:00:00Z",
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.workoutSplit).toBeUndefined();
    }
  });

  it("rejects invalid workoutSplit", () => {
    const result = UserProfile.safeParse({
      uid: "abc123",
      displayName: "John Doe",
      email: "jdoe@purdue.edu",
      workoutSplit: "invalid_split",
      createdAt: "2025-01-15T10:00:00Z",
      updatedAt: "2025-01-15T10:00:00Z",
    });
    expect(result.success).toBe(false);
  });
});

describe("WorkoutSplit", () => {
  it("accepts all valid split values", () => {
    for (const split of ["ppl", "upper_lower", "full_body", "bro_split"]) {
      expect(WorkoutSplit.safeParse(split).success).toBe(true);
    }
  });

  it("rejects invalid split values", () => {
    expect(WorkoutSplit.safeParse("push_pull").success).toBe(false);
    expect(WorkoutSplit.safeParse("").success).toBe(false);
    expect(WorkoutSplit.safeParse(123).success).toBe(false);
  });
});

describe("DailyPlan", () => {
  it("validates a plan with items", () => {
    const result = DailyPlan.safeParse({
      id: "2025-01-15",
      uid: "abc123",
      date: "2025-01-15",
      items: [
        {
          time: "07:00",
          duration: 60,
          activity: "Morning Workout - Upper Body",
          category: "gym",
          location: "CoRec Weight Room",
          notes: "Focus on bench press and rows",
        },
      ],
      generatedAt: "2025-01-15T06:00:00Z",
    });
    expect(result.success).toBe(true);
  });
});

describe("ChatRequest", () => {
  it("validates a chat request", () => {
    const result = ChatRequest.safeParse({
      message: "What exercises should I do today?",
      conversationHistory: [
        {
          role: "user",
          content: "Hello!",
          timestamp: "2025-01-15T10:00:00Z",
        },
        {
          role: "assistant",
          content: "Hi! How can I help with your fitness goals?",
          timestamp: "2025-01-15T10:00:01Z",
        },
      ],
    });
    expect(result.success).toBe(true);
  });

  it("rejects empty message", () => {
    const result = ChatRequest.safeParse({
      message: "",
    });
    expect(result.success).toBe(false);
  });
});

describe("FacilityUsageItem", () => {
  it("validates facility usage data", () => {
    const result = FacilityUsageItem.safeParse({
      facilityName: "CoRec Main Gym",
      currentCount: 142,
      maxCapacity: 300,
      lastUpdated: "2025-01-15T14:30:00Z",
    });
    expect(result.success).toBe(true);
  });
});
