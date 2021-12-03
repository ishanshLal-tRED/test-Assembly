import <iostream>;
import <chrono>;
import <thread>;
#include "header_misc.h";

void LinkedListPrefetch (void)
{
	using namespace std;

	constexpr int num_nodes = 8;
	LlNode *list1  = LlCreate (num_nodes);
	LlNode *list2a = LlCreate (num_nodes);
	LlNode *list2b = LlCreate (num_nodes);

	LlTraverse (list1);
	LlTraverseA_ (list2a);
	LlTraverseB_ (list2b);

	int node_fail;
	const char *fn = "LinkedListPrefetchResults.txt";
	
	cout << "Results for LinkedListPrefetch\n";
	if (LlCampare (num_nodes, list1, list2a, list2b, &node_fail))
		cout << "Linked List campare SUCCEDED\n";
	else
		cout << "Linked list campare FAILED - node_fail = " << node_fail << '\n';

	LlPrint (list1, fn, "-----list1-----", 0);
	LlPrint (list2a, fn, "-----list2a-----", 1);
	LlPrint (list2b, fn, "-----list2b-----", 1);

	cout << "Linked list results saved to file " << fn << '\n';

	LlDelete (list1);
	LlDelete (list2a);
	LlDelete (list2b);
}
int main ()
{
	LinkedListPrefetch ();
	std::this_thread::sleep_for ( std::chrono::seconds (2) );
	return 0;
}