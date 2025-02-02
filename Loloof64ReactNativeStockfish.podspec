require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "Loloof64ReactNativeStockfish"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms = { :ios => min_ios_version_supported }

  s.source       = { :git => "https://github.com/loloof64/ReactNativeStockfish.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}", "cpp/**/*.{hpp,cpp,c,h}"

  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
  }

  # Use install_modules_dependencies helper to install the dependencies if React Native version >=0.71.0.
  # See https://github.com/facebook/react-native/blob/febf6b7f33fdb4904669f99d795eba4c0f95d7bf/scripts/cocoapods/new_architecture.rb#L79.
  if respond_to?(:install_modules_dependencies, true)
    install_modules_dependencies(s)
  else
    # Don't install the dependencies when we run `pod install` in the old architecture.
    if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
      s.pod_target_xcconfig    = {
          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
          "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
      }
      s.dependency "React-Codegen"
      s.dependency "RCT-Folly"
      s.dependency "RCTRequired"
      s.dependency "RCTTypeSafety"
      s.dependency "ReactCommon/turbomodule/core"
    end
  end

  #-- add the path to the downloaded nnue files
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Loloof64ReactNativeStockfish/"'
  }
  
  #-- download nnue files
  s.script_phases = [
    {
      :name => 'Download Stockfish NNUE files',
      :execution_position => :before_compile,
      :script => <<-SCRIPT
        # setup variables
        NNUE_NAME_BIG="nn-1111cefa1111.nnue"
        NNUE_NAME_SMALL="nn-37f18f62d772.nnue"
        DOWNLOAD_BASE_URL="https://tests.stockfishchess.org/api/nn"
        STOCKFISH_SOURCES_DIR="${PODS_ROOT}/Loloof64ReactNativeStockfish/"

        # download
        mkdir -p $STOCKFISH_SOURCES_DIR
        curl -L -o "$STOCKFISH_SOURCES_DIR/$NNUE_NAME_BIG" "$DOWNLOAD_BASE_URL/$NNUE_NAME_BIG"
        curl -L -o "$STOCKFISH_SOURCES_DIR/$NNUE_NAME_SMALL" "$DOWNLOAD_BASE_URL/$NNUE_NAME_SMALL"
      SCRIPT
    }
  ]
end
