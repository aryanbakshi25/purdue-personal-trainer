"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FACILITY_CACHE_TTL_MS = exports.Collections = exports.IcsImportResponse = exports.IcsEvent = exports.IcsImportRequest = exports.ChatResponse = exports.ChatRequest = exports.ChatMessage = exports.ChatRole = exports.FacilityUsageItem = exports.DailyPlan = exports.PlanItem = exports.UserProfile = exports.FitnessLevel = exports.ScheduleBlock = exports.DayOfWeek = void 0;
var schemas_1 = require("./schemas");
Object.defineProperty(exports, "DayOfWeek", { enumerable: true, get: function () { return schemas_1.DayOfWeek; } });
Object.defineProperty(exports, "ScheduleBlock", { enumerable: true, get: function () { return schemas_1.ScheduleBlock; } });
Object.defineProperty(exports, "FitnessLevel", { enumerable: true, get: function () { return schemas_1.FitnessLevel; } });
Object.defineProperty(exports, "UserProfile", { enumerable: true, get: function () { return schemas_1.UserProfile; } });
Object.defineProperty(exports, "PlanItem", { enumerable: true, get: function () { return schemas_1.PlanItem; } });
Object.defineProperty(exports, "DailyPlan", { enumerable: true, get: function () { return schemas_1.DailyPlan; } });
Object.defineProperty(exports, "FacilityUsageItem", { enumerable: true, get: function () { return schemas_1.FacilityUsageItem; } });
Object.defineProperty(exports, "ChatRole", { enumerable: true, get: function () { return schemas_1.ChatRole; } });
Object.defineProperty(exports, "ChatMessage", { enumerable: true, get: function () { return schemas_1.ChatMessage; } });
Object.defineProperty(exports, "ChatRequest", { enumerable: true, get: function () { return schemas_1.ChatRequest; } });
Object.defineProperty(exports, "ChatResponse", { enumerable: true, get: function () { return schemas_1.ChatResponse; } });
Object.defineProperty(exports, "IcsImportRequest", { enumerable: true, get: function () { return schemas_1.IcsImportRequest; } });
Object.defineProperty(exports, "IcsEvent", { enumerable: true, get: function () { return schemas_1.IcsEvent; } });
Object.defineProperty(exports, "IcsImportResponse", { enumerable: true, get: function () { return schemas_1.IcsImportResponse; } });
/** Firestore collection paths */
exports.Collections = {
    USERS: "users",
    SCHEDULE_BLOCKS: (uid) => `users/${uid}/scheduleBlocks`,
    PLANS: (uid) => `users/${uid}/plans`,
    FACILITY_CACHE: "cache/facilityUsage",
};
/** Cache TTL in milliseconds (5 minutes) */
exports.FACILITY_CACHE_TTL_MS = 5 * 60 * 1000;
//# sourceMappingURL=index.js.map