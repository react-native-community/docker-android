
run-core:
	docker build -f Dockerfile.core --tag debian-react-native:android-29-jdk-8 .
	docker run --rm -ti debian-react-native:android-29-jdk-8

run:
	docker build --tag react-native-android:3.0 .
	docker run --rm -ti react-native-android:3.0
