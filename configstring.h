#include <map>
#include <list>

struct configstring_node_t {
    std::string data;
    std::map<std::string, configstring_node_t> children;
    configstring_node_t() : data(), children() {}
    configstring_node_t(std::string &datain) : data(datain), children() {}
};

// helper function
template <class T> std::list<T> make_list_with_init(T x) {
    std::list<T> l;
    l.push_back(x);
    return l;
}
