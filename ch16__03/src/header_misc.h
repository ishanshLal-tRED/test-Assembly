#pragma once

struct LlNode
{
	double ValA[4];
	double ValB[4];
	double ValC[4];
	double ValD[4];

	uint8_t FreeSpace[376];
	LlNode *link;
};
// defined in src_misc.cpp
extern bool LlCampare (int num_nodes, LlNode *l1, LlNode *l2, LlNode *l3, int *node_fail);
extern LlNode *LlCreate (int num_nodes);
extern void LlDelete (LlNode *p);
extern void LlTraverse (LlNode *p);
extern bool LlPrint (LlNode *p, const char *fn, const char *msg, bool append);

// defined in func.asm
extern "C" void LlTraverseA_ (LlNode* p);
extern "C" void LlTraverseB_ (LlNode* p);
