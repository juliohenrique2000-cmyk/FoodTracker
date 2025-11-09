-- CreateTable
CREATE TABLE "water_intakes" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "cups" INTEGER NOT NULL DEFAULT 0,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "water_intakes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "water_intakes_userId_date_key" ON "water_intakes"("userId", "date");

-- AddForeignKey
ALTER TABLE "water_intakes" ADD CONSTRAINT "water_intakes_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
