import SwiftUI

struct JyutpingView: View {
        
        @State private var inputText: String = String()
        private var jyutpings: [String] { JyutpingProvider.search(for: inputText) }
        
        private let placeholdText: String = NSLocalizedString("Search the Jyutping of Cantonese word", comment: "")
        
        var body: some View {
                NavigationView {
                        ScrollView {
                                Divider()
                                
                                EnhancedTextField(placeholder: placeholdText, text: $inputText)
                                        .padding(8)
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary).opacity(0.5))
                                        .padding()
                                
                                if !inputText.isEmpty {
                                        if jyutpings.isEmpty {
                                                HStack {
                                                        Text("No results.") + Text("\n") + Text("Common Cantonese words only.").font(.footnote)
                                                        Spacer()
                                                }
                                                .padding()
                                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                                .padding(.horizontal)
                                        } else {
                                                VStack {
                                                        HStack {
                                                                Text(inputText).font(.headline)
                                                        }
                                                        .padding(.top)
                                                        .padding(.horizontal)
                                                        
                                                        Divider()
                                                        
                                                        ForEach(jyutpings) { (jyutping) in
                                                                HStack {
                                                                        Text(jyutping)
                                                                                .font(.system(.body, design: .monospaced))
                                                                                .fixedSize(horizontal: false, vertical: true)
                                                                        Spacer()
                                                                }.padding(.horizontal)
                                                                
                                                                Divider()
                                                        }
                                                }
                                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                                .padding(.horizontal)
                                        }
                                }
                                
                                JyutpingTable().padding(.top, 30)
                                
                                HStack {
                                        Text("Search on other places (websites)").font(.headline)
                                        Spacer()
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                
                                SearchWebsitesView()
                                
                                HStack {
                                        Text("Jyutping resources").font(.headline)
                                        Spacer()
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 32)
                                
                                JyutpingWebsitesView()
                                        .padding(.bottom, 80)
                        }
                        .foregroundColor(.primary)
                        .navigationBarTitle(Text("Jyutping"))
                }
                .tabItem {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Jyutping")
                }
                .tag(2)
                .navigationViewStyle(StackNavigationViewStyle())
        }
}

struct JyutpingView_Previews: PreviewProvider {
        static var previews: some View {
                JyutpingView()
        }
}

extension String: Identifiable {
        public var id: UUID {
                return UUID()
        }
}

private struct JyutpingTable: View {
        var body: some View {
                VStack {
                        NavigationLink(destination: InitialsTable()) {
                                HStack {
                                        Text("粵拼聲母表")
                                        Spacer()
                                        Image(systemName: "chevron.right").opacity(0.5)
                                }
                                .padding(.top)
                                .padding(.horizontal)
                        }
                        Divider()
                        NavigationLink(destination: FinalsTable()) {
                                HStack {
                                        Text("粵拼韻母表")
                                        Spacer()
                                        Image(systemName: "chevron.right").opacity(0.5)
                                }
                                .padding(.horizontal)
                        }
                        Divider()
                        NavigationLink(destination: TonesTable()) {
                                HStack {
                                        Text("粵拼聲調表")
                                        Spacer()
                                        Image(systemName: "chevron.right").opacity(0.5)
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                }
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                .padding()
        }
}

struct SearchWebsitesView: View {
        var body: some View {
                VStack {
                        LinkButton(url: URL(string: "https://jyut.net")!,
                                   content: MessageView(icon: "doc.text.magnifyingglass",
                                                        text: Text("粵音資料集叢"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "https://words.hk")!,
                                   content: MessageView(icon: "doc.text.magnifyingglass",
                                                        text: Text("粵典"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "https://humanum.arts.cuhk.edu.hk/Lexis/lexi-can")!,
                                   content: MessageView(icon: "doc.text.magnifyingglass",
                                                        text: Text("粵語審音配詞字庫"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "https://www.jyutdict.org")!,
                                   content: MessageView(icon: "doc.text.magnifyingglass",
                                                        text: Text("泛粵大典"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "https://open-dict-data.github.io/ipa-lookup/yue")!,
                                   content: MessageView(icon: "doc.text.magnifyingglass",
                                                        text: Text("粵語國際音標查詢"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                }
                .padding(.bottom, 16)
        }
}

struct JyutpingWebsitesView: View {
        var body: some View {
                VStack {
                        LinkButton(url: URL(string: "https://www.jyutping.org")!,
                                   content: MessageView(icon: "link.circle",
                                                        text: Text("粵拼 jyutping.org"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "https://www.lshk.org/jyutping")!,
                                   content: MessageView(icon: "link.circle",
                                                        text: Text("LSHK Jyutping 粵拼"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "https://www.youtube.com/channel/UCcmAegX-cgcOOconZIwqynw")!,
                                   content: MessageView(icon: "link.circle",
                                                        text: Text("粵拼視頻教學 - YouTube"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "http://jyutping.lt.cityu.edu.hk")!,
                                   content: MessageView(icon: "link.circle",
                                                        text: Text("粵語拼音資源站 - CityU"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                        
                        LinkButton(url: URL(string: "http://www.iso10646hk.net/jp")!,
                                   content: MessageView(icon: "link.circle",
                                                        text: Text("粵拼 - iso10646hk.net"),
                                                        symbol: Image(systemName: "safari")))
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary))
                                .padding(.horizontal)
                }
                .padding(.bottom, 16)
        }
}
