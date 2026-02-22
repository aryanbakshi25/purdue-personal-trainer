export { DayOfWeek, ScheduleBlock, FitnessLevel, UserProfile, PlanItem, DailyPlan, FacilityUsageItem, ChatRole, ChatMessage, ChatRequest, ChatResponse, IcsImportRequest, IcsEvent, IcsImportResponse, } from "./schemas";
export type { DayOfWeek as DayOfWeekType, ScheduleBlock as ScheduleBlockType, FitnessLevel as FitnessLevelType, UserProfile as UserProfileType, PlanItem as PlanItemType, DailyPlan as DailyPlanType, FacilityUsageItem as FacilityUsageItemType, ChatRole as ChatRoleType, ChatMessage as ChatMessageType, ChatRequest as ChatRequestType, ChatResponse as ChatResponseType, IcsImportRequest as IcsImportRequestType, IcsEvent as IcsEventType, IcsImportResponse as IcsImportResponseType, } from "./schemas";
/** Firestore collection paths */
export declare const Collections: {
    readonly USERS: "users";
    readonly SCHEDULE_BLOCKS: (uid: string) => string;
    readonly PLANS: (uid: string) => string;
    readonly FACILITY_CACHE: "cache/facilityUsage";
};
/** Cache TTL in milliseconds (5 minutes) */
export declare const FACILITY_CACHE_TTL_MS: number;
