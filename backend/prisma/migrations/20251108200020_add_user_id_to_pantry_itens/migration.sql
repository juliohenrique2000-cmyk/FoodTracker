/*
  Warnings:

  - Added the required column `userId` to the `pantry_items` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "pantry_items" ADD COLUMN     "userId" INTEGER NOT NULL;

-- AddForeignKey
ALTER TABLE "pantry_items" ADD CONSTRAINT "pantry_items_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
