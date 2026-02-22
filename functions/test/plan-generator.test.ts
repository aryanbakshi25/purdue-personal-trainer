import { describe, it, expect } from "vitest";
import { generateDailyPlan } from "../src/services/plan-generator";
import type { UserProfileType, ScheduleBlockType } from "@ppt/shared";

const mockProfile: UserProfileType = {
  uid: "test-user",
  displayName: "Test User",
  email: "test@purdue.edu",
  fitnessLevel: "intermediate",
  goals: ["Build muscle", "Improve cardio"],
  preferredFacilities: ["CoRec"],
  createdAt: "2025-01-01T00:00:00Z",
  updatedAt: "2025-01-01T00:00:00Z",
};

const mockSchedule: ScheduleBlockType[] = [
  {
    id: "550e8400-e29b-41d4-a716-446655440001",
    title: "CS 252 Lecture",
    dayOfWeek: "wednesday",
    startTime: "09:30",
    endTime: "10:20",
    location: "LWSN B134",
    category: "class",
    isRecurring: true,
  },
  {
    id: "550e8400-e29b-41d4-a716-446655440002",
    title: "MA 265 Lecture",
    dayOfWeek: "wednesday",
    startTime: "11:30",
    endTime: "12:20",
    location: "UNIV 101",
    category: "class",
    isRecurring: true,
  },
  {
    id: "550e8400-e29b-41d4-a716-446655440003",
    title: "Work",
    dayOfWeek: "wednesday",
    startTime: "14:00",
    endTime: "17:00",
    location: "HAAS G066",
    category: "work",
    isRecurring: true,
  },
];

describe("generateDailyPlan", () => {
  // 2025-01-15 is a Wednesday
  const date = "2025-01-15";

  it("generates a plan with items", () => {
    const plan = generateDailyPlan("test-user", mockProfile, mockSchedule, date);

    expect(plan.uid).toBe("test-user");
    expect(plan.date).toBe(date);
    expect(plan.items.length).toBeGreaterThan(0);
    expect(plan.disclaimer).toContain("not medical advice");
  });

  it("includes the user's fitness level in workout suggestions", () => {
    const plan = generateDailyPlan("test-user", mockProfile, mockSchedule, date);
    const gymItems = plan.items.filter((i) => i.category === "gym");

    expect(gymItems.length).toBeGreaterThan(0);
    // Intermediate user should get push/pull suggestion
    const hasIntermediateWorkout = gymItems.some((i) =>
      i.activity.toLowerCase().includes("push/pull")
    );
    expect(hasIntermediateWorkout).toBe(true);
  });

  it("respects schedule blocks (no overlapping plan items)", () => {
    const plan = generateDailyPlan("test-user", mockProfile, mockSchedule, date);

    for (const item of plan.items) {
      for (const block of mockSchedule) {
        if (block.dayOfWeek !== "wednesday") continue;
        // Plan item should not start during a schedule block
        const itemStart = item.time;
        expect(
          itemStart < block.startTime || itemStart >= block.endTime
        ).toBe(true);
      }
    }
  });

  it("generates morning routine when no early classes", () => {
    const plan = generateDailyPlan("test-user", mockProfile, mockSchedule, date);
    const morningItems = plan.items.filter((i) => i.time < "08:00");

    expect(morningItems.length).toBeGreaterThan(0);
  });

  it("handles empty schedule", () => {
    const plan = generateDailyPlan("test-user", mockProfile, [], date);

    expect(plan.items.length).toBeGreaterThan(0);
  });
});
