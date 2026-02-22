import { z } from "zod";
export declare const DayOfWeek: z.ZodEnum<["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]>;
export type DayOfWeek = z.infer<typeof DayOfWeek>;
export declare const ScheduleBlock: z.ZodObject<{
    id: z.ZodString;
    title: z.ZodString;
    dayOfWeek: z.ZodEnum<["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]>;
    /** HH:mm in 24-hour format */
    startTime: z.ZodString;
    /** HH:mm in 24-hour format */
    endTime: z.ZodString;
    location: z.ZodOptional<z.ZodString>;
    /** e.g. "class", "work", "gym", "meal", "other" */
    category: z.ZodDefault<z.ZodString>;
    isRecurring: z.ZodDefault<z.ZodBoolean>;
}, "strip", z.ZodTypeAny, {
    id: string;
    title: string;
    dayOfWeek: "monday" | "tuesday" | "wednesday" | "thursday" | "friday" | "saturday" | "sunday";
    startTime: string;
    endTime: string;
    category: string;
    isRecurring: boolean;
    location?: string | undefined;
}, {
    id: string;
    title: string;
    dayOfWeek: "monday" | "tuesday" | "wednesday" | "thursday" | "friday" | "saturday" | "sunday";
    startTime: string;
    endTime: string;
    location?: string | undefined;
    category?: string | undefined;
    isRecurring?: boolean | undefined;
}>;
export type ScheduleBlock = z.infer<typeof ScheduleBlock>;
export declare const FitnessLevel: z.ZodEnum<["beginner", "intermediate", "advanced"]>;
export type FitnessLevel = z.infer<typeof FitnessLevel>;
export declare const UserProfile: z.ZodObject<{
    uid: z.ZodString;
    displayName: z.ZodString;
    email: z.ZodString;
    photoUrl: z.ZodOptional<z.ZodString>;
    fitnessLevel: z.ZodDefault<z.ZodEnum<["beginner", "intermediate", "advanced"]>>;
    goals: z.ZodDefault<z.ZodArray<z.ZodString, "many">>;
    preferredFacilities: z.ZodDefault<z.ZodArray<z.ZodString, "many">>;
    createdAt: z.ZodString;
    updatedAt: z.ZodString;
}, "strip", z.ZodTypeAny, {
    uid: string;
    displayName: string;
    email: string;
    fitnessLevel: "beginner" | "intermediate" | "advanced";
    goals: string[];
    preferredFacilities: string[];
    createdAt: string;
    updatedAt: string;
    photoUrl?: string | undefined;
}, {
    uid: string;
    displayName: string;
    email: string;
    createdAt: string;
    updatedAt: string;
    photoUrl?: string | undefined;
    fitnessLevel?: "beginner" | "intermediate" | "advanced" | undefined;
    goals?: string[] | undefined;
    preferredFacilities?: string[] | undefined;
}>;
export type UserProfile = z.infer<typeof UserProfile>;
export declare const PlanItem: z.ZodObject<{
    time: z.ZodString;
    duration: z.ZodNumber;
    activity: z.ZodString;
    category: z.ZodString;
    location: z.ZodOptional<z.ZodString>;
    notes: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    category: string;
    time: string;
    duration: number;
    activity: string;
    location?: string | undefined;
    notes?: string | undefined;
}, {
    category: string;
    time: string;
    duration: number;
    activity: string;
    location?: string | undefined;
    notes?: string | undefined;
}>;
export type PlanItem = z.infer<typeof PlanItem>;
export declare const DailyPlan: z.ZodObject<{
    id: z.ZodString;
    uid: z.ZodString;
    date: z.ZodString;
    items: z.ZodArray<z.ZodObject<{
        time: z.ZodString;
        duration: z.ZodNumber;
        activity: z.ZodString;
        category: z.ZodString;
        location: z.ZodOptional<z.ZodString>;
        notes: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        category: string;
        time: string;
        duration: number;
        activity: string;
        location?: string | undefined;
        notes?: string | undefined;
    }, {
        category: string;
        time: string;
        duration: number;
        activity: string;
        location?: string | undefined;
        notes?: string | undefined;
    }>, "many">;
    generatedAt: z.ZodString;
    disclaimer: z.ZodDefault<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    id: string;
    uid: string;
    date: string;
    items: {
        category: string;
        time: string;
        duration: number;
        activity: string;
        location?: string | undefined;
        notes?: string | undefined;
    }[];
    generatedAt: string;
    disclaimer: string;
}, {
    id: string;
    uid: string;
    date: string;
    items: {
        category: string;
        time: string;
        duration: number;
        activity: string;
        location?: string | undefined;
        notes?: string | undefined;
    }[];
    generatedAt: string;
    disclaimer?: string | undefined;
}>;
export type DailyPlan = z.infer<typeof DailyPlan>;
export declare const FacilityUsageItem: z.ZodObject<{
    facilityName: z.ZodString;
    currentCount: z.ZodNumber;
    maxCapacity: z.ZodNumber;
    lastUpdated: z.ZodString;
}, "strip", z.ZodTypeAny, {
    facilityName: string;
    currentCount: number;
    maxCapacity: number;
    lastUpdated: string;
}, {
    facilityName: string;
    currentCount: number;
    maxCapacity: number;
    lastUpdated: string;
}>;
export type FacilityUsageItem = z.infer<typeof FacilityUsageItem>;
export declare const ChatRole: z.ZodEnum<["user", "assistant"]>;
export type ChatRole = z.infer<typeof ChatRole>;
export declare const ChatMessage: z.ZodObject<{
    role: z.ZodEnum<["user", "assistant"]>;
    content: z.ZodString;
    timestamp: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    role: "user" | "assistant";
    content: string;
    timestamp?: string | undefined;
}, {
    role: "user" | "assistant";
    content: string;
    timestamp?: string | undefined;
}>;
export type ChatMessage = z.infer<typeof ChatMessage>;
export declare const ChatRequest: z.ZodObject<{
    message: z.ZodString;
    conversationHistory: z.ZodDefault<z.ZodArray<z.ZodObject<{
        role: z.ZodEnum<["user", "assistant"]>;
        content: z.ZodString;
        timestamp: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        role: "user" | "assistant";
        content: string;
        timestamp?: string | undefined;
    }, {
        role: "user" | "assistant";
        content: string;
        timestamp?: string | undefined;
    }>, "many">>;
}, "strip", z.ZodTypeAny, {
    message: string;
    conversationHistory: {
        role: "user" | "assistant";
        content: string;
        timestamp?: string | undefined;
    }[];
}, {
    message: string;
    conversationHistory?: {
        role: "user" | "assistant";
        content: string;
        timestamp?: string | undefined;
    }[] | undefined;
}>;
export type ChatRequest = z.infer<typeof ChatRequest>;
export declare const ChatResponse: z.ZodObject<{
    reply: z.ZodString;
    disclaimer: z.ZodDefault<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    disclaimer: string;
    reply: string;
}, {
    reply: string;
    disclaimer?: string | undefined;
}>;
export type ChatResponse = z.infer<typeof ChatResponse>;
export declare const IcsImportRequest: z.ZodObject<{
    icsUrl: z.ZodString;
}, "strip", z.ZodTypeAny, {
    icsUrl: string;
}, {
    icsUrl: string;
}>;
export type IcsImportRequest = z.infer<typeof IcsImportRequest>;
export declare const IcsEvent: z.ZodObject<{
    summary: z.ZodString;
    startTime: z.ZodString;
    endTime: z.ZodString;
    location: z.ZodOptional<z.ZodString>;
    recurrence: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    startTime: string;
    endTime: string;
    summary: string;
    location?: string | undefined;
    recurrence?: string | undefined;
}, {
    startTime: string;
    endTime: string;
    summary: string;
    location?: string | undefined;
    recurrence?: string | undefined;
}>;
export type IcsEvent = z.infer<typeof IcsEvent>;
export declare const IcsImportResponse: z.ZodObject<{
    events: z.ZodArray<z.ZodObject<{
        summary: z.ZodString;
        startTime: z.ZodString;
        endTime: z.ZodString;
        location: z.ZodOptional<z.ZodString>;
        recurrence: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        startTime: string;
        endTime: string;
        summary: string;
        location?: string | undefined;
        recurrence?: string | undefined;
    }, {
        startTime: string;
        endTime: string;
        summary: string;
        location?: string | undefined;
        recurrence?: string | undefined;
    }>, "many">;
    warnings: z.ZodDefault<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    events: {
        startTime: string;
        endTime: string;
        summary: string;
        location?: string | undefined;
        recurrence?: string | undefined;
    }[];
    warnings: string[];
}, {
    events: {
        startTime: string;
        endTime: string;
        summary: string;
        location?: string | undefined;
        recurrence?: string | undefined;
    }[];
    warnings?: string[] | undefined;
}>;
export type IcsImportResponse = z.infer<typeof IcsImportResponse>;
