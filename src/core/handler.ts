export function handleRequest(input: any) {
  if (!input) throw new Error("Input required");
  return { success: true, processed: true };
}