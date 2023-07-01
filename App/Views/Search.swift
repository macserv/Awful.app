//  Search.swift
//
//  Copyright 2023 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

import SwiftUI
import HTMLReader
import AwfulCore


@available(iOS 14.0, *)
struct SearchResultsView: View {
    @ObservedObject var model: SearchPageViewModel
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @SwiftUI.Environment(\.theme) var theme
    
    var body: some View {
        NavigationView {
       
                VStack(alignment: .center)  {
                   
                        ScrollView {
                            ForEach(Array(zip(self.model.searchResults.indices, self.model.searchResults)), id: \.1.id) { (index, searchResult) in
                                
                                Button (action: {
                                    self.model.resultsViewVisible = false
                                    presentationMode.wrappedValue.dismiss()
                                    AppDelegate.instance.open(route: .post(id: searchResult.postID, .noseen))
                                    
                                }) {
                                    SearchResultCard(resultNumber: searchResult.resultNumber,
                                                     threadTitle: searchResult.threadTitle,
                                                     postedDateTime: searchResult.postedDateTime,
                                                     blurb: searchResult.blurb)
                                
                            }
                        }
                    }
                }
                .navigationBarTitle(Text("Search results"), displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Back") {
                            self.model.searchViewVisible = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Exit") {
                            self.model.searchViewVisible = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

@available(iOS 14.0, *)
struct SearchResultCard: View {
    @SwiftUI.Environment(\.theme) var theme
    
    let resultNumber: String
    let threadTitle: String
    let postedDateTime: String
    let blurb: String
   
    var body: some View {
      
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(resultNumber)
                        Text(threadTitle)
                    }
                    .font(.subheadline)
                    .lineLimit(nil)
                    
                    
                    Text(postedDateTime)
                        .foregroundColor(.black)
                        .font(.subheadline)
                }
                .foregroundColor(.blue)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                VStack(alignment: .leading) {
                    Text(blurb)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .foregroundColor(.black)
                        .lineLimit(nil)
                        .font(.body)
                }
        }
            
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8))
            .foregroundColor(theme[swiftColor: "sheetBackgroundColor"]!)
    }
}


@available(iOS 14.0, *)
struct SearchView: View {
    @ObservedObject var model: SearchPageViewModel
    @SwiftUI.Environment(\.theme) var theme
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if self.model.searchViewVisible {
            NavigationView {
                VStack(alignment: .center)  {
                    VStack(alignment: .leading) {
                        TextField("Search", text: self.$model.userQueryString)
                            .font(.title2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                        
                        
                        Text("Example searches:")
                        ForEach(Array(zip(self.model.searchHelpHints.indices, self.model.searchHelpHints)), id: \.1.id) { (index, hint) in
                            Text(hint.text)
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }
                    }
                    .font(.caption)
                    .frame(maxWidth: 600)
                    
                    VStack {
                        Button(action: {
                            for index in self.model.forumSelectOptions.indices {
                                self.model.forumSelectOptions[index].isSelected.toggle()
                            }
                        }){
                            Text("Toggle all")
                        }
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .foregroundColor(theme[swiftColor: "tintColor"]!)
                        
                        Spacer()
                        ScrollView {
                            ForEach(Array(zip(self.model.forumSelectOptions.indices, self.model.forumSelectOptions)), id: \.1.id) { (index, forumSelectOption) in
                                Button (action: {
                                    self.model.forumSelectOptions[index].isSelected.toggle()
                                }) {
                                    
                                    Toggle(isOn: self.$model.forumSelectOptions[index].isSelected){
                                        Text("\(forumSelectOption.optionText)")
                                    }
                                    .toggleStyle(CheckboxToggleStyle())
                                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                    
                                }
                                .contentShape(Rectangle())
                            }
                        }
                        
                    }
                    .frame(maxWidth: 600)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .background(theme[swiftColor: "sheetBackgroundColor"]!.edgesIgnoringSafeArea(.all))
                .foregroundColor(theme[swiftColor: "listTextColor"]!)
                .onAppear {
                    Task.init(priority: .userInitiated) {
                        await self.model.scrapeForumSelectOptions(htmlString: self.model.searchPageHTMLString)
                    }
                }
                .navigationBarTitle(Text("Search forums"), displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Exit") {
                            self.model.searchViewVisible = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Search") {
                            Task.init(priority: .userInitiated) {
                                await self.model.performSearch()
                            }
                        }
                    }
                }
            }
            //   .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .navigationViewStyle(StackNavigationViewStyle())
        }
        
        if self.model.resultsViewVisible {
            SearchResultsView(model: self.model)
        }
    }
}







@available(iOS 14.0, *)
struct SearchResultCard_Previews: PreviewProvider {

    static let testTheme = Theme.theme(named: "brightLight") // change this to preview different themes
    ?? Theme.defaultTheme()
   
    static var previews: some View {
        VStack {
            SearchResultCard(resultNumber: "1.", threadTitle: "Thread title blah blah blah Thread title blah blah blah Thread title blah blah blah Thread title blah blah blah", postedDateTime: "by Plinkey in C-SPAM at Jul 1, 2023 8:04 PM", blurb: "do his job instead of getting an easy payday, the bane of every mercenary's existence. So Julie and friends escape. Finally, I roll a negotiation test with some pretty heft negatives for Julie to get a room at the Gates Undersound. Especially since she's a minor and rolls up in a Mad Maxmobile")
            SearchResultCard(resultNumber: "1.", threadTitle: "Thread title blah blah blah", postedDateTime: "by Plinkey in C-SPAM at Jul 1, 2023 8:04 PM", blurb: "do his job instead of getting an easy payday, the bane of every mercenary's existence. So Julie and friends escape. Finally, I roll a negotiation test with some pretty heft negatives for Julie to get a room at the Gates Undersound. Especially since she's a minor and rolls up in a Mad Maxmobile")
            SearchResultCard(resultNumber: "1.", threadTitle: "Thread title blah blah blah", postedDateTime: "by Plinkey in C-SPAM at Jul 1, 2023 8:04 PM", blurb: "do his job instead of getting an easy payday, the bane of every mercenary's existence. So Julie and friends escape. Finally, I roll a negotiation test with some pretty heft negatives for Julie to get a room at the Gates Undersound. Especially since she's a minor and rolls up in a Mad Maxmobile")
        }
        
      
    }
}


class SearchPageViewModel: ObservableObject {
    @Published var searchPageHtmlDoc: HTMLDocument = .init(string: "")
    @Published var searchResultsHtmlDoc: HTMLDocument = .init(string: "")
    @Published var userQueryString: String = ""
    @Published var searchMessage: String = ""
    @Published var searchResultInfo: String = ""
    @Published var forumSelectOptions: [ForumSelectOption]
    @Published var searchResults: [SearchResult]
    @Published var searchPageHTMLString: String
    @Published var searchHelpHints: [SearchHelpHint]
    @Published var searchResultsHtmlString: String = ""
    @Published var searchViewVisible: Bool = true
    @Published var resultsViewVisible: Bool = false
    
    init(forumSelectOptions: [ForumSelectOption] = [],
         searchPageHTMLString: String = "",
         searchHelpHints: [SearchHelpHint] = [],
         searchResults: [SearchResult] = []
    ) {
        self.forumSelectOptions = forumSelectOptions
        self.searchPageHTMLString = searchPageHTMLString
        self.searchHelpHints = []
        self.searchResults = []
    }
    
    
    
    
    
    @MainActor
    func scrapeForumSelectOptions(htmlString: String) async {
        var htmlString = ""
        htmlString = SearchPageViewModel.searchPageHTMLString
        self.searchPageHtmlDoc = try! htmlString2HtmlDocument(htmlString: htmlString)
        
        if let forumListHtmlDoc = self.searchPageHtmlDoc.firstNode(matchingSelector: "form[action='query.php']") {
            if let searchMessage = forumListHtmlDoc.firstNode(matchingSelector: ".search_message") {
                self.searchMessage = searchMessage.textContent
            } else {
                self.searchMessage = ""
            }
            
            if let searchHelpText = forumListHtmlDoc.firstNode(matchingSelector: ".search_help") {
                for helpMessage in searchHelpText.nodes(matchingSelector: ".term"){
                    var helpHint = SearchHelpHint()
                    helpHint.text = helpMessage.textContent
                    self.searchHelpHints.append(helpHint)
                }
            }
            
            for input in self.searchPageHtmlDoc.nodes(matchingSelector: ".forumcheck") {
                var option = ForumSelectOption()
                option.optionText = input.parent?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                option.value = input["value"]
                
                if option.optionText != "Select All Forums" {
                    self.forumSelectOptions.append(option)
                }
            }
        }
    }
    
    @MainActor
    func scrapeForumResultsPage(htmlString: String) async {
     
        self.searchResultsHtmlDoc = try! htmlString2HtmlDocument(htmlString: htmlString)
        
        if let resultHtmlDoc = self.searchResultsHtmlDoc.firstNode(matchingSelector: "form[action='query.php']") {
            if let searchResultInfo = resultHtmlDoc.firstNode(matchingSelector: "#search_info") {
                self.searchResultInfo = searchResultInfo.textContent
            } else {
                self.searchResultInfo = ""
            }
            
            
            for searchResult in self.searchResultsHtmlDoc.nodes(matchingSelector: ".search_result") {
                var result = SearchResult()
                
                result.threadTitle = searchResult.firstNode(matchingSelector: ".threadtitle")?.textContent ?? ""
                result.resultNumber = searchResult.firstNode(matchingSelector: ".result_number")?.textContent ?? ""
                result.blurb = searchResult.firstNode(matchingSelector: ".blurb")?.textContent ?? ""
                result.forumTitle = searchResult.firstNode(matchingSelector: ".forumtitle")?.textContent ?? ""
                result.userName = searchResult.firstNode(matchingSelector: ".username")?.textContent ?? ""
                
                result.postID = searchResult.firstNode(matchingSelector: ".threadtitle")
                    .flatMap { $0["href"] }
                    .flatMap { URLComponents(string: $0) }
                    .flatMap { $0.queryItems }
                    .flatMap { $0.first(where: { $0.name == "postid" }) }
                    .flatMap { $0.value }
                ?? ""
                
                result.postedDateTime = searchResult.firstNode(matchingSelector: ".hit_info")?.textContent ?? ""
                
                self.searchResults.append(result)
                
            }
        }
    }
    
    @MainActor
    func performSearch() async {
        var components = URLComponents()
        components.path = "query.php"
        components.queryItems = [
            URLQueryItem(name: "q", value: self.userQueryString),
            URLQueryItem(name: "action", value: "query")
        ]
        
        self.forumSelectOptions.filter { $0.isSelected }.forEach {
            components.queryItems?.append(URLQueryItem(name: "forums[]", value: $0.value))
        }
        
        var urlRequest = URLRequest(url: components.url(relativeTo: ForumsClient.shared.baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        guard let queryItems = components.queryItems, !queryItems.isEmpty else { return }
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        guard let queryItemString = queryString.data(using: .utf8) else { return }
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: queryItemString)
            
            // Handle success
            guard let searchResultsHtmlString = String(data: data, encoding: .utf8) else { return }
            
            if let httpResponse = response as? HTTPURLResponse {
            
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 302  {
                    self.searchResultsHtmlString = searchResultsHtmlString
                    self.searchViewVisible = false
                    self.resultsViewVisible = true
                    await self.scrapeForumResultsPage(htmlString: searchResultsHtmlString)
                   
                }
            }
        } catch {
            // Handle error
            print("Error: \(error)")
        }
        
    }
    
    func htmlString2HtmlDocument(htmlString: String) throws -> HTMLDocument {
        return HTMLDocument(string: htmlString)
    }
}

struct ForumSelectOption: Identifiable, Equatable {
    var optionText = ""
    var value = ""
    var name = ""
    let id = UUID()
    var isSelected: Bool = false
}

struct SearchResult: Identifiable, Equatable {
    var threadTitle = ""
    var resultNumber = ""
    var blurb = ""
    var forumTitle = ""
    let id = UUID()
    var postID = ""
    var userName = ""
    var postedDateTime = ""
    var highlight = ""
}

struct SearchHelpHint: Identifiable, Equatable {
    var text = ""
    let id = UUID()
}




extension SearchPageViewModel {
    static let searchPageHTMLString = """
                            <form action="query.php" method="post" accept-charset="UTF-8">
                            <div class="search_container">
                            <div class="search_message standard">
                            Thread with ID 3495489 was not found
                            </div>
                            <div class="search_form standard">
                            <h1>Search the forums<span class="beta">BETA</span></h1>
                            <input name="q" type="text" id="query" value="threadid:3495489 quoting:&quot;Jeffrey of YOSPOS&quot; username:&quot;Poor Jesus&quot; boat" autofocus /><br />
                            <button type="submit" name="action" value="query">Search</button><br />
                            </div>
                            <div class="search_help">
                            <div class="title">Example Searches</div>
                            <div class="term">intitle:"dog breath" userid:75630 blund</div>
                            <div class="term">"gaming crimes" since:"last monday" before:"2 days ago"</div>
                            <div class="term">threadid:3858657 quoting:"Jeffrey of YOSPOS" username:"Teen Jesus" sand</div>
                            <div style="margin-top:16px; font-weight: bold">Notice: We are still fine tuning the search engine to serve you better! Try simple queries or constrain your search to a particular forum.</div>
                            <div style="margin-top:16px; font-weight: bold">Tip: Click or tap on a forum or category name to toggle the checkboxes for all of its subforums!</div>
                            </div>
                            <div class="clearfix forumlist_container standard">
                            <div class="forumlist">
                            <button type="button" data-forumid="-1" class="search_forum depth0">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="-1">
                            Select All Forums
                            </button>
                            <div data-forumid="48" class="search_forum depth0  ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="48">
                            Main
                            </div>
                            <div data-forumid="272" class="search_forum depth1  parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="272">
                            The Great Outdoors
                            </div>
                            <div data-forumid="273" class="search_forum depth1  parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="273">
                            General Bullshit
                            </div>
                            <div data-forumid="669" class="search_forum depth2  parent273 parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="669">
                            Fuck You and Dine
                            </div>
                            <div data-forumid="155" class="search_forum depth2  parent273 parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="155">
                            SA's Front Page Discussion
                            </div>
                            <div data-forumid="214" class="search_forum depth2  parent273 parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="214">
                            Everyone's/Neurotic
                            </div>
                             <div data-forumid="26" class="search_forum depth1  parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="26">
                            FYAD
                            </div>
                            <div data-forumid="167" class="search_forum depth1  parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="167">
                            Post Your Favorite/Request
                            </div>
                            <div data-forumid="670" class="search_forum depth2  parent167 parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="670">
                            Post My Favorites
                            </div>
                            <div data-forumid="268" class="search_forum depth1  parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="268">
                            BYOB
                            </div>
                            <div data-forumid="196" class="search_forum depth2  parent268 parent48 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="196">
                            Cool Crew Chat Central
                            </div>
                            <div data-forumid="51" class="search_forum depth0  ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="51">
                            Discussion
                            </div>
                            <div data-forumid="44" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="44">
                            Video Games
                            </div>
                            <div data-forumid="191" class="search_forum depth2  parent44 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="191">
                            Let's Play!
                            </div>
                            <div data-forumid="146" class="search_forum depth2  parent44 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="146">
                            WoW: Goon Squad
                            </div>
                            <div data-forumid="145" class="search_forum depth2  parent44 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="145">
                            The MMO HMO
                            </div>
                            <div data-forumid="279" class="search_forum depth2  parent44 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="279">
                            Mobile Gaming
                            </div>
                            <div data-forumid="278" class="search_forum depth2  parent44 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="278">
                            Retro Games
                            </div>
                            <div data-forumid="93" class="search_forum depth2  parent44 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="93">
                            Private Game Servers
                            </div>
                            <div data-forumid="234" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="234">
                            Traditional Games
                            </div>
                            <div data-forumid="103" class="search_forum depth2  parent234 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="103">
                            The Game Room
                            </div>
                            <div data-forumid="46" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="46">
                            Debate &amp; Discussion
                            </div>
                            <div data-forumid="269" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="269">
                            C-SPAM
                            </div>
                             <div data-forumid="158" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="158">
                            Ask/Tell
                            </div>
                            <div data-forumid="162" class="search_forum depth2  parent158 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="162">
                            Science, Academics and Languages
                            </div>
                            <div data-forumid="211" class="search_forum depth2  parent158 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="211">
                            Tourism &amp; Travel
                            </div>
                            <div data-forumid="200" class="search_forum depth2  parent158 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="200">
                            Business, Finance, and Careers
                            </div>
                            <div data-forumid="22" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="22">
                            Serious Hardware/Software Crap
                            </div>
                            <div data-forumid="170" class="search_forum depth2  parent22 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="170">
                            Haus of Tech Support
                            </div>
                            <div data-forumid="202" class="search_forum depth2  parent22 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="202">
                            The Cavern of COBOL
                            </div>
                            <div data-forumid="265" class="search_forum depth3  parent202 parent22 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="265">
                            project.log
                            </div>
                            </div>
                            <div class="forumlist">
                            <div data-forumid="219" class="search_forum depth2  parent22 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="219">
                            YOSPOS
                            </div>
                            <div data-forumid="192" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="192">
                            Inspect Your Gadgets
                            </div>
                            <div data-forumid="122" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="122">
                            Sports Argument Stadium
                            </div>
                            <div data-forumid="181" class="search_forum depth2  parent122 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="181">
                            The Football Funhouse
                            </div>
                            <div data-forumid="175" class="search_forum depth2  parent122 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="175">
                            The Ray Parlour
                            </div>
                            <div data-forumid="248" class="search_forum depth2  parent122 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="248">
                            The Armchair Quarterback
                            </div>
                            <div data-forumid="139" class="search_forum depth2  parent122 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="139">
                            Poker Is Totally Rigged
                            </div>
                            <div data-forumid="177" class="search_forum depth2  parent122 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="177">
                            Punch Sport Pagoda
                            </div>
                             <div data-forumid="179" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="179">
                            You Look Like Shit
                            </div>
                            <div data-forumid="183" class="search_forum depth2  parent179 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="183">
                            The Goon Doctor
                            </div>
                            <div data-forumid="244" class="search_forum depth2  parent179 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="244">
                            The Fitness Log Cabin
                            </div>
                            <div data-forumid="161" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="161">
                            Goons With Spoons
                            </div>
                            <div data-forumid="91" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="91">
                            Automotive Insanity
                            </div>
                            <div data-forumid="236" class="search_forum depth2  parent91 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="236">
                            Cycle Asylum
                            </div>
                            <div data-forumid="210" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="210">
                            Hobbies, Crafts, &amp; Houses
                            </div>
                            <div data-forumid="124" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="124">
                            Pet Island
                            </div>
                            <div data-forumid="132" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="132">
                            The Firing Range
                            </div>
                            <div data-forumid="277" class="search_forum depth2  parent132 parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="277">
                            The Pellet Palace
                            </div>
                            <div data-forumid="90" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="90">
                            The Crackhead Clubhouse
                            </div>
                            <div data-forumid="218" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="218">
                            Internet VFW
                            </div>
                            <div data-forumid="275" class="search_forum depth1  parent51 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="275">
                            The Minority Rapport
                            </div>
                            <div data-forumid="152" class="search_forum depth0  ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="152">
                            The Finer Arts
                            </div>
                            <div data-forumid="267" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="267">
                            Imp Zone
                            </div>
                            <div data-forumid="681" class="search_forum depth2  parent267 parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="681">
                            The Enclosed Pool Area
                            </div>
                            <div data-forumid="274" class="search_forum depth2  parent267 parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="274">
                            Blockbuster Video
                            </div>
                            <div data-forumid="668" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="668">
                            The Sci-Fi Wifi
                            </div>
                            <div data-forumid="151" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="151">
                            Cinema Discusso
                            </div>
                            <div data-forumid="133" class="search_forum depth2  parent151 parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="133">
                            The Film Dump
                            </div>
                            <div data-forumid="150" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="150">
                            No Music Discussion
                            </div>
                            <div data-forumid="104" class="search_forum depth2  parent150 parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="104">
                            Musician's Lounge
                            </div>
                            <div data-forumid="215" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="215">
                            PHIZ
                            </div>
                            </div>
                            <div class="forumlist">
                            <div data-forumid="31" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="31">
                            Creative Convention
                            </div>
                            <div data-forumid="247" class="search_forum depth2  parent31 parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="247">
                            The Dorkroom
                            </div>
                            <div data-forumid="182" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="182">
                            The Book Barn
                            </div>
                            <div data-forumid="688" class="search_forum depth2  parent182 parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="688">
                            The Scholastic Book Fair
                            </div>
                            <div data-forumid="130" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="130">
                            TV IV
                            </div>
                            <div data-forumid="255" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="255">
                            Rapidly Going Deaf
                            </div>
                            <div data-forumid="144" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="144">
                            BSS: Bisexual Super Son
                            </div>
                            <div data-forumid="27" class="search_forum depth1  parent152 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="27">
                            Anime Directly to Readers Worldwide
                            </div>
                            <div data-forumid="153" class="search_forum depth0  ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="153">
                            The Community
                            </div>
                            <div data-forumid="61" class="search_forum depth1  parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="61">
                            SA-Mart
                            </div>
                            <div data-forumid="77" class="search_forum depth2  parent61 parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="77">
                            Feedback &amp; Discussion
                            </div>
                            <div data-forumid="85" class="search_forum depth2  parent61 parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="85">
                            Coupons &amp; Deals
                            </div>
                            <div data-forumid="241" class="search_forum depth1  parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="241">
                            LAN: Your City Sucks
                            </div>
                            <div data-forumid="43" class="search_forum depth2  parent241 parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="43">
                            Goon Meets
                            </div>
                            <div data-forumid="686" class="search_forum depth1  parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="686">
                            Something Awful Discussion
                            </div>
                            <div data-forumid="687" class="search_forum depth2  parent686 parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="687">
                            Resolved, Closed, or Duplicate SAD Threads
                            </div>
                            <div data-forumid="676" class="search_forum depth1  parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="676">
                            Technical Enquiries Contemplated Here
                            </div>
                            <div data-forumid="689" class="search_forum depth2  parent676 parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="689">
                            Goon Rush
                            </div>
                            <div data-forumid="677" class="search_forum depth2  parent676 parent153 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="677">
                            Resolved Technical Forum Missives
                            </div>
                            <div data-forumid="49" class="search_forum depth0  ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="49">
                            Archives
                            </div>
                            <div data-forumid="21" class="search_forum depth1  parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="21">
                            Comedy Goldmine
                            </div>
                            <div data-forumid="680" class="search_forum depth2  parent21 parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="680">
                            Imp Zone: Player's Choice
                            </div>
                            <div data-forumid="264" class="search_forum depth2  parent21 parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="264">
                            The Goodmine
                            </div>
                            <div data-forumid="115" class="search_forum depth2  parent21 parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="115">
                            FYAD: Criterion Collection
                            </div>
                            <div data-forumid="222" class="search_forum depth2  parent21 parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="222">
                            LF Goldmine
                            </div>
                            <div data-forumid="176" class="search_forum depth2  parent21 parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="176">
                            BYOB Goldmine: Gold Mango
                            </div>
                            <div data-forumid="25" class="search_forum depth1  parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="25">
                            Toxic Comedy Gas Waste Chamber Dump
                            </div>
                            <div data-forumid="1" class="search_forum depth1  parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="1">
                            GBS Graveyard
                            </div>
                            <div data-forumid="675" class="search_forum depth1  parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="675">
                            Questions, Comments, Suggestions
                            </div>
                            <div data-forumid="188" class="search_forum depth2  parent675 parent49 ">
                            <input type="checkbox" class="forumcheck" name="forums[]" value="188">
                            QCS Success Stories
                            </div>
                            </div>
                            </div>
                            </div>
                            </form>
                            """
    
    static let searchResultsHTMLString = """
                                        <!DOCTYPE html>
                                        <html>
                                        <head>
                                        <title>Search Results - The Something Awful Forums</title>
                                        <meta http-equiv="X-UA-Compatible" content="chrome=1">
                                        <script src="/cdn-cgi/apps/head/c5Rt4EMPiK30f4U3Qayhvmm6FoM.js"></script><link rel="apple-touch-icon" href="//i.somethingawful.com/core/icon/iphone-touch/forums.png">
                                        <link rel="stylesheet" type="text/css" href="https://i.somethingawful.com/css/main.css?29">
                                        <link rel="stylesheet" type="text/css" href="https://i.somethingawful.com/css/bbcode.css?1456974412">


                                        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/themes/smoothness/jquery-ui.min.css" integrity="sha512-vljQ8u3XOuV0u0GLG6ZRToEi2ZKCWeJwezv27POKmq/s1MIRiSv32m5MKZaquL4WIdh3A0wE+HChNH+s6psFFQ==" crossorigin="anonymous" referrerpolicy="no-referrer" />
                                        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.1/jquery.min.js" integrity="sha512-aVKKRRi/Q/YV+4mjoKBsE4x3H+BkegoM/em46NNlCqNTmUYADjBbeNefNxYV7giUp0VxICtqdrbqU7iVaeZNXA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
                                        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-migrate/3.4.0/jquery-migrate.min.js" integrity="sha512-QDsjSX1mStBIAnNXx31dyvw4wVdHjonOwrkaIhpiIlzqGUCdsI62MwQtHpJF+Npy2SmSlGSROoNWQCOFpqbsOg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
                                        <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js" integrity="sha512-BHDCWLtdp0XpAFccP2NifCbJfYoYhsRSZOUM3KnAxy2b/Ay3Bn91frud+3A95brA4wDWV3yEOZrJqgV8aZRXUQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
                                        <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Roboto:400,700,500,900,400italic,500italic,700italic">
                                        <link rel="stylesheet" type="text/css" href="https://i.somethingawful.com/css/forums.css?1545838492">
                                        <script type="text/javascript">
                                                                adjust_page_position = true;                    </script>
                                        <script type="text/javascript" src="https://i.somethingawful.com/js/forums.combined.js?1476414338"></script>
                                        <link rel="stylesheet" type="text/css" href="https://i.somethingawful.com/css/search.css?2" />
                                        <link rel="stylesheet" type="text/css" href="https://i.somethingawful.com/css/newsearch.css" />
                                        <script src="https://i.somethingawful.com/js/search.js" type="text/javascript"></script>
                                        </head>
                                        <body id="something_awful" class="searchresults">
                                        <div id="container">
                                        <ul id="nav_purchase">
                                        <li><b>Purchase:</b></li>
                                        <li><a href="https://store.somethingawful.com/products/register.php">Account</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/platinum.php">Platinum Upgrade</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/titlechange.php">New Avatar</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/archives.php">Archives</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/noads.php">No-Ads</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/namechange.php">New Username</a></li>
                                        <li>- <a href="https://www.patreon.com/SomethingAwful"><span class="purch_new">Donate on Patreon</span></a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/ad-banner.php">Banner Advertisement</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/smilie.php">Smilie</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/sticky-thread.php">Stick Thread</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/gift-certificate.php">Gift Cert.</a></li>
                                        <li>- <a href="https://store.somethingawful.com/products/donate.php">Donations!</a></li>
                                        </ul>
                                        <ul id="navigation" class="navigation">
                                        <li class="first"><a href="/index.php">SA Forums</a></li>
                                        <li>- <a href="https://www.somethingawful.com/frontpage/">Something Awful</a></li>
                                        <li>- <a href="/query.php">Search the Forums</a></li>
                                        <li>- <a href="/usercp.php">User Control Panel</a></li>
                                        <li>- <a href="/private.php">Private Messages</a></li>
                                        <li>- <a href="/member.php?action=editoptions">Edit Options</a></li>
                                        <li>- <a href="https://www.somethingawful.com/d/forum-rules/forum-rules.php">Forum Rules</a></li>
                                        <li>- <a href="/dictionary.php">SAclopedia</a></li>
                                        <li>- <a href="/stats.php">Posting Gloryhole</a></li>
                                        <li>- <a href="/banlist.php">Leper's Colony</a></li>
                                        <li>- <a href="/supportmail.php">Support</a></li>
                                        <li>- <a href="/account.php?action=logout&amp;ma=782d089d">Log Out</a></li>
                                        </ul>
                                        <div id="content">
                                        <form action="query.php" method="post">
                                        <div class="search_container">
                                        <div id="search_info">
                                        Searched for posts which meet the following criteria:
                                        <hr>
                                        <div>Text contains the term &#039;test&#039;</div>
                                        <hr>
                                        Showing results 1 to 10 of 1000 results. Query took 0.32 seconds to complete.
                                        </div>
                                        <ul id="search_results">
                                        <ul class="pages">
                                        <li class="page_number">
                                        <span class="this_page">1</span>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=2">2</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=3">3</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=4">4</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=5">5</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=6">6</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=7">7</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=8">8</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=9">9</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=10">10</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=11">11</a>
                                        </li>
                                        <li class="next_page">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=2">Next</a>
                                        </li>
                                        <li class="last_page">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=100">Last</a>
                                        </li>
                                        </ul><br /><br />
                                        <li class="search_result">
                                        <div class="result_number">1.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532903997&amp;highlight=test#post532903997">{Trump} mostly funny but sometimes it gets depressing</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=60513">Plinkey</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=269">C-SPAM</a> at Jul 1, 2023 8:04 PM</div>
                                        <div class="blurb">there should be a <em>test</em> to be a goon, you would not make it</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">2.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532903334&amp;highlight=test#post532903334">tech bubble v5.8: Strap in for more enshittification</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=138869">4lokos basilisk</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=219">YOSPOS</a> at Jul 1, 2023 6:21 PM</div>
                                        <div class="blurb">recently i witnessed a presentation about an automated system for updating npm dependencies and automerging the result to the main branch if the <em>test</em> suite runs
                                        nothing can possibly go wrong here</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">3.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532903159&amp;highlight=test#post532903159">cjs: my first code change broke an internal tool after passing multiple levels of review</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=52813">bump_fn</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=219">YOSPOS</a> at Jul 1, 2023 5:55 PM</div>
                                        <div class="blurb">
                                        the air puff machine is an update of the glaucoma <em>test</em> (testing the pressure of your eyeball) they used to jsut poke it with a stick</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">4.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532903015&amp;highlight=test#post532903015">OSHA IV: delta P is stored in the ballasts</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=93251">LvK</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=273">General Bullshit</a> at Jul 1, 2023 5:32 PM</div>
                                        <div class="blurb">
                                        dying from smoke inhalation because my floor is on fire and the only egress to ground floor is a staircase being used to stress-<em>test</em> 40s and I am too preoccupied cheering for Steel Reserve to descend</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">5.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532902846&amp;highlight=test#post532902846">Spook-A-Doodle Movie Club &amp; Bracketology Tournament '23</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=133275">STAC Goat</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=151">Cinema Discusso</a> at Jul 1, 2023 5:11 PM</div>
                                        <div class="blurb">Well I didn't like Strange Behavior much. Maybe some raw potential but just kind of cold and dull and it failed the basic <em>test</em> of keeping me in my seat the whole time. And man those kids sure looked 35. And they're partying to 60s music. Either Australia has a curious idea of American teenagers in the 80s or this is an elaborate 21 Jump Street style sting.
                                        Guess I gotta rewatch Witch to figure out where to vote.</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">6.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532902749&amp;highlight=test#post532902749">(CYOA) Blake Island School of Magic (Shadowrun Fifth Edition)</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=114300">Ice Phisherman</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=103">The Game Room</a> at Jul 1, 2023 5:03 PM</div>
                                        <div class="blurb"> do his job instead of getting an easy payday, the bane of every mercenary's existence. So Julie and friends escape.
                                        Finally, I roll a negotiation <em>test</em> with some pretty heft negatives for Julie to get a room at the Gates Undersound. Especially since she's a minor and rolls up in a Mad Maxmobile</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">7.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532902589&amp;highlight=test#post532902589">The Physical Media Thread: It's not a very good movie but I'll buy it.</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=220741">Steen71</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=151">Cinema Discusso</a> at Jul 1, 2023 4:46 PM</div>
                                        <div class="blurb">Holy shit, the upscaling they did on the UHD of Avatar is... something. The live action stuff is essentially Avatar: The Water Colour Painting.
                                        https://i.imgur.com/q6dymC5.jpg[/img]
                                        [img]https://i.imgur.com/Nzi4kg3.jpg
                                        More here: https://caps-a-holic.com/c.php?d1=18258&d2=18257&s1=211127&s2=211099&i=1&l=0&a=0[/url]
                                        And here: [url]https://www.hdnumerique.com/dossiers/1145-<em>test</em>-4k-ultra-hd-blu-ray-avatar.html</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">8.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532902232&amp;highlight=test#post532902232">[C-SPAM Feedback] If you see something, say something. Our Mods are standing by.</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=213131">16-bit Butt-Head</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=269">C-SPAM</a> at Jul 1, 2023 4:15 PM</div>
                                        <div class="blurb">
                                        we need to <em>test</em> this by making them each draw a clock</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">9.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532901958&amp;highlight=test#post532901958">Test Cricket, Best Cricket</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=109918">webmeister</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=122">Sports Argument Stadium</a> at Jul 1, 2023 3:53 PM</div>
                                        <div class="blurb"> point and bangs on about it for an hour. Quite like Ponting though, feel like he’s the happiest to call things straight, speaks his mind and obviously knows an awful lot
                                        Strauss on comms this <em>test</em> keeps confusing me, because he sounds almost identical to Vish from the Football Ramble podcast</div>
                                        </li>
                                        <li class="search_result">
                                        <div class="result_number">10.</div>
                                        <div class="threadlink"><a class="threadtitle" href="/showthread.php?goto=post&amp;noseen=1&amp;postid=532901310&amp;highlight=test#post532901310">She fucking lit my right hand up when I grabbed her tutu [June Chat Thread]</a></div>
                                        <div class="hit_info">by <a class="username" href="/member.php?action=getinfo&amp;userid=211341">tarlibone</a> in <a class="forumtitle" href="/forumdisplay.php?forumid=132">The Firing Range</a> at Jul 1, 2023 2:56 PM</div>
                                        <div class="blurb">
                                        That's... sort-of true. I get those when certain biting bugs get me, but it just itches. It's more of a histamine reaction than an infection.
                                        The real <em>test</em> is, is the red part hot to the touch? If the red part is spreading out and it's swollen and/or warmer to the touch than the non-red</div>
                                        </li>
                                        </ol>
                                        <ul class="pages">
                                        <li class="page_number">
                                        <span class="this_page">1</span>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=2">2</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=3">3</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=4">4</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=5">5</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=6">6</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=7">7</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=8">8</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=9">9</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=10">10</a>
                                        </li>
                                        <li class="page_number">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=11">11</a>
                                        </li>
                                        <li class="next_page">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=2">Next</a>
                                        </li>
                                        <li class="last_page">
                                        <a href="/query.php?action=results&amp;qid=1688208552&amp;page=100">Last</a>
                                        </li>
                                        </il>
                                        </div>
                                        </form>
                                        </div>
                                        <ul class="navigation">
                                        <li class="first"><a href="/index.php">SA Forums</a></li>
                                        <li>- <a href="https://www.somethingawful.com/frontpage/">Something Awful</a></li>
                                        <li>- <a href="/query.php">Search the Forums</a></li>
                                        <li>- <a href="/usercp.php">User Control Panel</a></li>
                                        <li>- <a href="/private.php">Private Messages</a></li>
                                        <li>- <a href="/member.php?action=editoptions">Edit Options</a></li>
                                        <li>- <a href="https://www.somethingawful.com/d/forum-rules/forum-rules.php">Forum Rules</a></li>
                                        <li>- <a href="/dictionary.php">SAclopedia</a></li>
                                        <li>- <a href="/stats.php">Posting Gloryhole</a></li>
                                        <li>- <a href="/banlist.php">Leper's Colony</a></li>
                                        <li>- <a href="/supportmail.php">Support</a></li>
                                        <li>- <a href="/account.php?action=logout&amp;ma=782d089d">Log Out</a></li>
                                        </ul>
                                        <div id="copyright">
                                        Powered by: vBulletin Version 2.2.9 (<a href="/CHANGES">SABB-v2.23.07</a>)<br>
                                        Copyright &copy;2000, 2001, Jelsoft Enterprises Limited.<br>
                                        Copyright &copy;2023, Jeffrey of YOSPOS<br>
                                        </div>
                                        </div>
                                        </body>
                                        </html>

                                        """
    
}

// thanks to https://swiftwithmajid.com/2020/03/04/customizing-toggle-in-swiftui/
struct CheckboxToggleStyle: ToggleStyle {
    @SwiftUI.Environment(\.isEnabled) var isEnabled
    @SwiftUI.Environment(\.theme) var theme
    
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
                .font(.body)
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : isEnabled ? "square" : "square.fill")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(configuration.isOn ? theme[swiftColor: "tintColor"]! : isEnabled ? theme[swiftColor: "listTextColor"]! : theme[swiftColor: "placeholderTextColor"]!)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
