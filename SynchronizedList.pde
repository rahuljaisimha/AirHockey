public class SynchronizedList<T> implements Iterable{
  private ArrayList<T> list;
  
  SynchronizedList() {
    list = new ArrayList<T>();
  }
  
  public synchronized void add(T t) {
    list.add(t);
  }
  
  public synchronized void remove(int a) {
    list.remove(a);
  }
  
  public synchronized void remove(T t) {
    list.remove(t);
  }
  
  public synchronized T get(int a) {
    return list.get(a);
  }
  
  public synchronized int size() {
    return list.size();
  }
  
  public synchronized boolean contains(int a) {
    return list.contains(a);
  }
  
  public synchronized Iterator iterator() {
    return list.iterator();
  }
  
}
