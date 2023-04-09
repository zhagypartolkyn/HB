 

import SwiftUI

struct ReportView: View {
    @State var selected: String = ""
    @State private var commentText: String = ""
    @State private var reportType: ReportType?
    
    var sendPressed: ((_ type: ReportType?, _ comment: String) -> Void)?
    var closePressed: (() -> Void)?
    
    var data = ReportType.allCases
    
    var body: some View {
        ZStack {
            Color(UIColor.appColor(.backgroundSecondary)).edgesIgnoringSafeArea(.all)
            
            
            VStack {
                HStack(alignment: .center, spacing: 16) {
                    Button(action: {
                        closePressed?()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(AssetsColor.primary.rawValue))
                    }
                    Text("Жалоба").font(.title)
                    Spacer()
                }.padding(.leading)
                .padding(.top)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(data, id: \.self) { item in
                            Button(action: {
                                self.selected = item.rawValue
                                self.reportType = item
                            }) {
                                HStack {
                                    Text(item.rawValue).font(.body)
                                    Spacer()
                                    
                                    ZStack {
                                        Circle().fill(
                                            self.selected == item.rawValue ?
                                                Color(UIColor.appColor(.primary)) :
                                                Color(.clear)
                                        ).frame(width: 10, height: 10)
                                        
                                        Circle().stroke(Color(
                                                            self.selected == item.rawValue ?
                                                            AssetsColor.primary.rawValue :
                                                            AssetsColor.textSecondary.rawValue
                                        ), lineWidth: 2.0).frame(width: 16, height: 16)
                                    }
                                }
                                .padding(.horizontal)
                                .foregroundColor(Color(AssetsColor.textPrimary.rawValue))
                            }
                            Divider()
                        }
                        VStack(alignment: .leading) {
                            Text("Комментарий модератору")
                                .foregroundColor(Color(AssetsColor.textSecondary.rawValue))
                            TextField("Опишите  причину жалобы", text: $commentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }.padding(.top, 12)
                }
                
                Button(action: {
                    sendPressed?(reportType, commentText)
                }) {
                    Text("Отправить")
                        .fontWeight(.bold)
                        .padding(.all, 12)
                        .foregroundColor(Color.white)
                        .font(.body)
                        .frame(minWidth: 200, maxWidth: .infinity)
                        .background(Color(AssetsColor.primary.rawValue))
                        .cornerRadius(Constants.Radius.general)
                }.padding(.horizontal)
                
            }
        }
    }
    
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
