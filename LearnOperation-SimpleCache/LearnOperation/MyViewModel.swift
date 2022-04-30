//
//  MyViewModel.swift
//  LearnOperation
//
//  Created by brown on 2022/4/30.
//

import Foundation

struct MyViewModel {
    typealias Callback = (_ data: [MyModel]) -> Void
    var success: Callback
    var failure: Callback
    
    init(success: @escaping Callback, failure: @escaping Callback) {
        self.success = success
        self.failure = failure
        self.loadData()
    }
    
    private func loadData() {
        let titleArray: [String] = ["典雅的教堂","高清无码美女",
                                    "典雅的教堂","西湖美女","毛笔执念","毛笔执念", "西湖美女", "高清无码美女","西湖美女","毛笔执念","毛笔执念", "西湖美女", "高清无码美女","西湖美女","毛笔执念","毛笔执念", "西湖美女", "高清无码美女","典雅的教堂","高清无码美女",
                                    "典雅的教堂","西湖美女","123123", "123123123"]
        
        let imageUrlArray: [String] = [
            
                "http://c.hiphotos.baidu.com/image/h%3D300/sign=f60add2afc1f3a2945c8d3cea924bce3/fd039245d688d43ffdcaed06711ed21b0ff43be6.jpg",
                "http://e.hiphotos.baidu.com/image/h%3D300/sign=0708e32319ce36d3bd0485300af23a24/fcfaaf51f3deb48fd0e9be27fc1f3a292cf57842.jpg",
                "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2255216145,2300317876&fm=27&gp=0.jpg",
                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3023900356,2704941131&fm=27&gp=0.jpg",
                "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=138591535,3556328424&fm=27&gp=0.jpg",
                "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=632034377,1155764629&fm=27&gp=0.jpg",
                "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=632034377,1155764629&fm=27&gp=0.jpg",
                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=240111376,3607275229&fm=27&gp=0.jpg",
                "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3482407582,2023034431&fm=27&gp=0.jpg",
                "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1706218755,2318976317&fm=27&gp=0.jpg",
                "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2444259859,2134277926&fm=27&gp=0.jpg",
                "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=4238908152,1331251418&fm=27&gp=0.jpg",
            "http://c.hiphotos.baidu.com/image/h%3D300/sign=f60add2afc1f3a2945c8d3cea924bce3/fd039245d688d43ffdcaed06711ed21b0ff43be6.jpg",
            "http://e.hiphotos.baidu.com/image/h%3D300/sign=0708e32319ce36d3bd0485300af23a24/fcfaaf51f3deb48fd0e9be27fc1f3a292cf57842.jpg",
            "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2255216145,2300317876&fm=27&gp=0.jpg",
            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3023900356,2704941131&fm=27&gp=0.jpg",
            "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=138591535,3556328424&fm=27&gp=0.jpg",
            "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=632034377,1155764629&fm=27&gp=0.jpg",
            "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=632034377,1155764629&fm=27&gp=0.jpg",
            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=240111376,3607275229&fm=27&gp=0.jpg",
            "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3482407582,2023034431&fm=27&gp=0.jpg",
            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1706218755,2318976317&fm=27&gp=0.jpg",
            "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2444259859,2134277926&fm=27&gp=0.jpg",
            "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=4238908152,1331251418&fm=27&gp=0.jpg",
        ]
        
        let models: [MyModel] = zip(imageUrlArray, titleArray).map(MyModel.init)
        success(models)
    }
}
