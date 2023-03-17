// @ts-nocheck
 
export const actions = {
  default: async ({ cookies, request }) => {
    const resjson = Object.fromEntries(await request?.formData())

    console.table(resjson);
    return { success: true };
  }
};