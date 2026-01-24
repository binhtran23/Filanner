-- CreateEnum
CREATE TYPE "RequestStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');

-- CreateTable
CREATE TABLE "finance_plan" (
    "id" TEXT NOT NULL,
    "userId" INTEGER NOT NULL,
    "userName" TEXT NOT NULL,
    "userInfo" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "finance_plan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "planExchange" (
    "id" SERIAL NOT NULL,
    "financePlanId" TEXT NOT NULL,
    "plan" TEXT,
    "responseTime" INTEGER NOT NULL,
    "successCode" INTEGER NOT NULL DEFAULT 200,
    "errorMessage" TEXT,
    "status" "RequestStatus" NOT NULL DEFAULT 'PENDING',
    "promptTokens" INTEGER,
    "completionTokens" INTEGER,
    "totalTokens" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "planExchange_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "finance_plan_userId_idx" ON "finance_plan"("userId");

-- CreateIndex
CREATE INDEX "planExchange_financePlanId_idx" ON "planExchange"("financePlanId");

-- AddForeignKey
ALTER TABLE "planExchange" ADD CONSTRAINT "planExchange_financePlanId_fkey" FOREIGN KEY ("financePlanId") REFERENCES "finance_plan"("id") ON DELETE CASCADE ON UPDATE CASCADE;
