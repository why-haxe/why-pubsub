package why;

interface PubSub<Pub, Sub> {
	final publishers:Pub;
	final subscribers:Sub;
}

