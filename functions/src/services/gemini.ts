import { VertexAI } from "@google-cloud/vertexai";
import type { ChatMessageType } from "@ppt/shared";

const PROJECT_ID = "scab-purdue";
const LOCATION = "us-central1";
const MODEL = "gemini-2.0-flash";

/**
 * Calls Gemini via Vertex AI with user context and conversation history.
 *
 * IMPORTANT: This is server-side only. The API key / credentials
 * never leave the Cloud Functions environment.
 *
 * Authentication:
 * - In production: uses the Cloud Functions service account (automatic).
 * - In emulators: set GOOGLE_APPLICATION_CREDENTIALS to a service account
 *   key file, or use `gcloud auth application-default login`.
 *
 * To use the Gemini REST API with an API key instead, store the key
 * in Secret Manager and access it via:
 *   defineSecret("GEMINI_API_KEY")
 * See: https://firebase.google.com/docs/functions/config-env
 */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
interface UserContext {
  profile: Record<string, unknown> | null;
  scheduleBlocks: Record<string, unknown>[];
  todayPlan: Record<string, unknown> | null;
  facilityUsage: Record<string, unknown>[];
}

const SYSTEM_INSTRUCTION = `You are a helpful fitness assistant for Purdue University students.
You help users plan workouts, understand their schedule, and make the most of campus recreation facilities.

IMPORTANT GUARDRAILS:
- You are NOT a doctor or medical professional. Never provide medical diagnoses or treatment plans.
- Always include a brief disclaimer when giving fitness advice.
- If a user describes symptoms of injury or illness, recommend they visit the Purdue Student Health Center (PUSH).
- Keep responses concise and actionable.
- You have access to the user's schedule, fitness profile, and current facility usage data.
- When suggesting workout times, consider their class schedule and facility crowding.
- Be encouraging but realistic about fitness goals.`;

export async function callGemini(
  userMessage: string,
  conversationHistory: ChatMessageType[],
  context: UserContext
): Promise<string> {
  const vertexAi = new VertexAI({
    project: PROJECT_ID,
    location: LOCATION,
  });

  const model = vertexAi.getGenerativeModel({
    model: MODEL,
    systemInstruction: {
      parts: [{ text: SYSTEM_INSTRUCTION }],
      role: "system",
    },
    generationConfig: {
      maxOutputTokens: 1024,
      temperature: 0.7,
      topP: 0.9,
    },
    safetySettings: [
      {
        category: "HARM_CATEGORY_DANGEROUS_CONTENT" as never,
        threshold: "BLOCK_MEDIUM_AND_ABOVE" as never,
      },
    ],
  });

  // Build context message
  const contextParts: string[] = [];
  if (context.profile) {
    contextParts.push(
      `User Profile: ${JSON.stringify(context.profile, null, 2)}`
    );
  }
  if (context.scheduleBlocks.length > 0) {
    contextParts.push(
      `Schedule: ${JSON.stringify(context.scheduleBlocks, null, 2)}`
    );
  }
  if (context.todayPlan) {
    contextParts.push(
      `Today's Plan: ${JSON.stringify(context.todayPlan, null, 2)}`
    );
  }
  if (context.facilityUsage.length > 0) {
    contextParts.push(
      `Current Facility Usage: ${JSON.stringify(context.facilityUsage, null, 2)}`
    );
  }

  // Build conversation history for the model
  const contents = [];

  // Add context as first user message if available
  if (contextParts.length > 0) {
    contents.push({
      role: "user" as const,
      parts: [
        {
          text: `[Context for this conversation - do not repeat this to the user]\n${contextParts.join("\n\n")}`,
        },
      ],
    });
    contents.push({
      role: "model" as const,
      parts: [
        {
          text: "Understood. I have the user's context. How can I help?",
        },
      ],
    });
  }

  // Add conversation history
  for (const msg of conversationHistory) {
    contents.push({
      role: msg.role === "user" ? ("user" as const) : ("model" as const),
      parts: [{ text: msg.content }],
    });
  }

  // Add current message
  contents.push({
    role: "user" as const,
    parts: [{ text: userMessage }],
  });

  const result = await model.generateContent({ contents });
  const response = result.response;

  const text =
    response.candidates?.[0]?.content?.parts?.[0]?.text ??
    "I'm sorry, I couldn't generate a response. Please try again.";

  return text;
}
