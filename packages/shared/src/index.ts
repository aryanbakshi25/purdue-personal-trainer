export {
  DayOfWeek,
  ScheduleBlock,
  FitnessLevel,
  WorkoutSplit,
  UserProfile,
  PlanItem,
  DailyPlan,
  FacilityUsageItem,
  ChatRole,
  ChatMessage,
  ChatRequest,
  ChatResponse,
  IcsImportRequest,
  IcsEvent,
  IcsImportResponse,
} from "./schemas";

export type {
  DayOfWeek as DayOfWeekType,
  ScheduleBlock as ScheduleBlockType,
  FitnessLevel as FitnessLevelType,
  WorkoutSplit as WorkoutSplitType,
  UserProfile as UserProfileType,
  PlanItem as PlanItemType,
  DailyPlan as DailyPlanType,
  FacilityUsageItem as FacilityUsageItemType,
  ChatRole as ChatRoleType,
  ChatMessage as ChatMessageType,
  ChatRequest as ChatRequestType,
  ChatResponse as ChatResponseType,
  IcsImportRequest as IcsImportRequestType,
  IcsEvent as IcsEventType,
  IcsImportResponse as IcsImportResponseType,
} from "./schemas";

/** Firestore collection paths */
export const Collections = {
  USERS: "users",
  SCHEDULE_BLOCKS: (uid: string) => `users/${uid}/scheduleBlocks`,
  PLANS: (uid: string) => `users/${uid}/plans`,
  FACILITY_CACHE: "cache/facilityUsage",
} as const;

/** Cache TTL in milliseconds (5 minutes) */
export const FACILITY_CACHE_TTL_MS = 5 * 60 * 1000;
